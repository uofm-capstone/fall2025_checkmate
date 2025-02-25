module Semesters
class RepositoriesController < ApplicationController
    #HTTParty is a gem that you can use to easily make API calls. The first argument is a URL. Then can provide header information.
    include HTTParty

    #The repositories_controller got a makeover between versions 1 and 2
    #Version 1 has the code for showing the GitHub metrics
    #Version 2 is updated to the standard scaffolding, but still needs the GitHub metrics code added back in and adapted

    def show
        # @semester = Semester.find(params[:semester_id])
        # @repo = Repository.find(params[:repo_id])
        # @sprint = Sprint.find(params[:sprint_id])
        @semester = 4
        @repo = 2
        @sprint = 'Sprint 4'

        session[:repo_id] = params[:repo_id]
        session[:repo_sprint_id] = params[:sprint_id]

        #Setting up the URLs for API calls. This uses GitHub's REST API v3. https://docs.github.com/en/rest
        issues_url="https://api.github.com/repos/#{@repo.owner}/#{@repo.repo_name}/issues?state=all"
        pullrequests_url="https://api.github.com/repos/#{@repo.owner}/#{@repo.repo_name}/pulls?state=all"
        pullrequest_reviews_url="https://api.github.com/repos/#{@repo.owner}/#{@repo.repo_name}/pulls/"
        commits_url="https://api.github.com/repos/#{@repo.owner}/#{@repo.repo_name}/commits?per_page=100&since=#{@sprint.start_date}&until=#{@sprint.end_date}"
        contributors_url="https://api.github.com/repos/#{@repo.owner}/#{@repo.repo_name}/contributors"
        if current_user.github_token
        then
            #Need to have authorization token. This is where the GitHub API key is needed.
            #Response is stored in a variable
            contributors_request = HTTParty.get(contributors_url,:headers => {"Authorization" => "Bearer #{current_user.github_token}","Accept" => "application/json"})

            #Use the JSON parse command to create an array (or hash?) based on the JSON response from the API
            begin
                @contributors_array = JSON.parse(contributors_request.body)
            rescue => exception
                @contributors_array = "Could not retrieve list of contributors. This repository may not have any contributors yet."
            end
            begin
                @contrib = []
                @contributors_array.each do |issue|
                    @contrib.push(issue[%Q(login)])
                end
            rescue => e
                has_access = false
            end

            if has_access == false
                redirect_to session.delete(:return_to), alert: "This repo is set to private, Please be given access and generate a token to use the GIT API"
            else
                # Uncomment to get issues list from API. There is not currently any processing of issues on show page. Note that API issue requests cannot be filtered by date, but you could do some parsing of the results to keep the ones created/updated/closed since a certain time, etc.
                issues_request = HTTParty.get(issues_url,:headers => {"Authorization" => "Bearer #{current_user.github_token}","Accept" => "application/json"})
                @issues_hash = JSON.parse(issues_request.body)
                @issue_titles = []
                @issue_created = []
                @issue_closed = []
                @issue_url = []
                @issue_user = []
                @issue_login = []
                @issues_hash.each do |issue|
                    if issue[%Q(closed_at)]  && Time.parse(issue[%Q(closed_at)]) > @sprint.start_date && Time.parse(issue[%Q(closed_at)]) < @sprint.end_date && issue[%Q(html_url)].exclude?("pull")
                        @issue_titles.push(issue[%Q(title)])
                        @issue_created.push(Time.parse(issue[%Q(created_at)]))
                        @issue_closed.push(Time.parse(issue[%Q(closed_at)]))
                        @issue_url.push(issue[%Q(html_url)])
                        @issue_user.push(issue[%Q(assignee)])


                    end
                end

                @issue_user.each do |user|
                    @issue_login.push(user[%Q(login)])
                end

                pullrequests_request = HTTParty.get(pullrequests_url,:headers => {"Authorization" => "Bearer #{current_user.github_token}","Accept" => "application/json"})
                #Don't remember why I named some hashes and some arrays
                pullrequests_api_results = JSON.parse(pullrequests_request.body)
                @pr_review_array = []
                @pr_assigned_array = []
                @pullrequests_review = []

                #This only keeps PRs that have actually been merged.
                pullrequests_api_results.each do |pr|
                    if pr[%Q(merged_at)] && Time.parse(pr[%Q(merged_at)]) > @sprint.start_date && Time.parse(pr[%Q(merged_at)]) < @sprint.end_date
                        review_request = (HTTParty.get(pullrequest_reviews_url + "#{pr[%Q(number)]}/reviews",:headers => {"Authorization" => "Bearer #{current_user.github_token}","Accept" => "application/json"}))
                        @pr_review_array.push(JSON.parse(review_request.body))
                        @pr_assigned_array.push(pr)
                        @pullrequests_review.push(pr[%Q(requested_reviewers)])
                    end
                end
                commits_request = HTTParty.get(commits_url,:headers => {"Authorization" => "Bearer #{current_user.github_token}","Accept" => "application/json"})
                @commits_array = JSON.parse(commits_request.body)
            end

        else
            redirect_to semesters_path, alert: "Please add a valid GitHub API key"
        end
    end

    def new
        @semester = Semester.find(params[:semester_id])
        @repository = Repository.new
        # render 'semesters/repositories/new'

        render :new
    end

    def create
        @repository = Repository.new(user_id: current_user.id, owner: params[:owner].strip, repo_name: params[:repo_name].strip, team: params[:team_name].strip)
        if @repository.save!
            redirect_to semesters_path, notice: 'The repository has been successfully added!'
        else
            flash.now[:alert] = 'Error! Unable to add new repository.'
            render :new
        end
    end
end
end
