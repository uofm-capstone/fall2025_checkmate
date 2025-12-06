# app/services/github_service.rb
require "octokit"

class GithubService
  def initialize(token: ENV["GITHUB_PAT"])
    @client = Octokit::Client.new(access_token: token)
    if true
      user = @client.user
      puts "Authenticated as: #{user.login}"
      puts "User ID: #{user.id}"
      puts "Name: #{user.name}"
      puts "Email: #{user.email}"
    end
  end

  # Fetch commits in date range
  def commits_in_range(repo, start_date, stop_date)
    commits = []
    page = 1

    loop do
      batch = @client.commits(
        repo,
        per_page: 100,
        page: page,
        since: start_date,
        until: stop_date
      )

      break if batch.empty?

      commits.concat(batch)
      page += 1
    end

    commits
  end

  # Filter commits by username
  def commits_by_user(commits, username)
    commits.select do |c|
      login = c.author&.login
      email_name = c.commit.author.name
      login == username || email_name == username
    end
  end

  CardInfo = Struct.new(:title, :status, :assignees, :fields, :type)
  def project_cards(project_url)
    org    = project_url.split("/")[4]
    number = project_url.split("/").last.to_i

    query = <<~GRAPHQL
      query($org: String!, $number: Int!) {
        organization(login: $org) {
          projectV2(number: $number) {
            title
            items(first: 50) {
              nodes {
                id

                # Underlying content on the card: Issue, PR, or DraftIssue
                content {
                  __typename
                  ... on Issue {
                    title
                    url
                    assignees(first: 10) {
                      nodes {
                        login
                        name
                      }
                    }
                  }
                  ... on PullRequest {
                    title
                    url
                    assignees(first: 10) {
                      nodes {
                        login
                        name
                      }
                    }
                  }
                  ... on DraftIssue {
                    title
                  }
                }

                # Project-level fields (Status, custom fields, Assignees, etc.)
                fieldValues(first: 20) {
                  nodes {
                    __typename

                    ... on ProjectV2ItemFieldTextValue {
                      text
                      field { ... on ProjectV2FieldCommon { name } }
                    }

                    ... on ProjectV2ItemFieldSingleSelectValue {
                      name
                      field { ... on ProjectV2FieldCommon { name } }
                    }

                    ... on ProjectV2ItemFieldNumberValue {
                      number
                      field { ... on ProjectV2FieldCommon { name } }
                    }

                    ... on ProjectV2ItemFieldUserValue {
                      users(first: 10) {
                        nodes {
                          login
                          name
                        }
                      }
                      field { ... on ProjectV2FieldCommon { name } }
                    }
                  }
                }
              }
            }
          }
        }
      }
    GRAPHQL

    variables = { org: org, number: number }

    begin
      # Call GitHub GraphQL API
      result = @client.post "graphql", { query: query, variables: variables }.to_json

      # Navigate down into the response to get the project
      project = result.dig(:data, :organization, :projectV2)
      unless project
        puts "No project found or access denied."
        return []
      end

      # Get the list of item hashes (each item is a card on the project)
      items = project.dig(:items, :nodes) || []
      if items.empty?
        puts "No items found."
        return []
      end

      cards = []

      items.each do |item|
        content = item[:content] || {}

        # Type is "Issue", "PullRequest", or "DraftIssue"
        type       = content[:__typename]
        item_title = content[:title] || "(no title)"

        # Build a simple hash of project fields:
        # { "Status" => "Backlog", "Time Estimate" => 3.0, "Completion Time" => 5.0, "Assignees" => ["user1"] }
        fields = {}

        (item.dig(:fieldValues, :nodes) || []).each do |fv|
          field_name = fv.dig(:field, :name)
          next unless field_name

          case fv[:__typename]
          when "ProjectV2ItemFieldTextValue"
            fields[field_name] = fv[:text]
          when "ProjectV2ItemFieldSingleSelectValue"
            fields[field_name] = fv[:name]
          when "ProjectV2ItemFieldNumberValue"
            fields[field_name] = fv[:number]
          when "ProjectV2ItemFieldUserValue"
            users = (fv.dig(:users, :nodes) || []).map { |u| u[:login] || u[:name] }
            fields[field_name] = users
          end
        end

        # Status (board column) is stored as a single-select field named "Status"
        status = fields["Status"]
        status = status.first if status.is_a?(Array)

        # Repo-level assignees for real Issues / PRs
        issue_assignees =
          if %w[Issue PullRequest].include?(type)
            (content.dig(:assignees, :nodes) || []).map { |u| u[:login] || u[:name] }
          else
            []
          end

        # Project-level assignees field.
        # DraftIssues do not have repo assignees, so they use this field instead.
        project_assignees = fields["Assignees"]

        # Final assignees:
        # 1) Prefer repo assignees (for Issues / PRs)
        # 2) Otherwise use project "Assignees" field (for DraftIssues, etc.)
        assignees =
          if issue_assignees.any?
            issue_assignees
          elsif project_assignees.is_a?(Array)
            project_assignees
          elsif project_assignees
            Array(project_assignees)
          else
            []
          end

        # Create a CardInfo instance and add it to the result array
        card = CardInfo.new(item_title, status, assignees, fields, type)
        cards.push(card)
      end

      # Return the list of CardInfo objects
      return cards

    rescue => e
      puts "Error in project_test: #{e.class} - #{e.message}"
      return []
    end
  end

  # FS&D: Number of cards per column
  def get_card_count_per_column(project_cards)
    column_counts = Hash.new(0)

    project_cards.each do |card|
      status = card.status || "Unspecified"
      column_counts[status] += 1
    end

    return column_counts
  end

  # FA: Number of cards assigned to each team member
  def get_card_count_per_assignee(project_cards, usernames = [])
    assignee_counts = Hash.new(0)

    project_cards.each do |card|
      card.assignees.each do |assignee|
        if usernames.include?(assignee)
          assignee_counts[assignee] += 1
        end
      end
    end

    return assignee_counts
  end

  # TE: Sum of estimated hours per team member

  # CBP: Count of commits and line changes
  CBPResult = Struct.new(:commit_count, :lines_added, :lines_removed, :lines_changed)
  def get_commit_info(repo, username, commits, start_date, end_date)
    user_commits = commits_by_user(commits, username)

    total_added = 0
    total_removed = 0

    user_commits.each do |c|
      detailed = @client.commit(repo, c.sha)

      # Safely handle commits without stats
      added    = detailed.stats&.additions.to_i
      removed  = detailed.stats&.deletions.to_i

      total_added   += added
      total_removed += removed
    end

    total_changed = total_added + total_removed

    CBPResult.new(
      user_commits.count,
      total_added,
      total_removed,
      total_changed
    )
  end

  def get_commit_info_old(repo, username, start_date, end_date)
    commits = commits_in_range(repo, start_date, end_date)
    user_commits = commits_by_user(commits, username)

    total_added = 0
    total_removed = 0

    user_commits.each do |c|
      detailed = @client.commit(repo, c.sha)

      # Safely handle commits without stats
      added    = detailed.stats&.additions.to_i
      removed  = detailed.stats&.deletions.to_i

      total_added   += added
      total_removed += removed
    end

    total_changed = total_added + total_removed

    CBPResult.new(
      user_commits.count,
      total_added,
      total_removed,
      total_changed
    )
  end

  # TSP: Work hours or updates since last check

end