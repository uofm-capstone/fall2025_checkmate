require 'csv'

def get_git_info()
  # Read CSV data from the file
  csv = CSV.read('/Users/naitik/Downloads/Github Info.csv', headers: true)

  # Initialize dictionaries to hold start and end dates for each sprint
  start_dates = {}
  end_dates = {}

  # Initialize dictionaries for repo owners, repo names, and GitHub access tokens indexed by team names
  repo_owners = {}
  repo_names = {}
  access_tokens = {}
  team_names = []

  # Iterate over each row in the CSV data
  csv.each do |row|
    sprint_number = row["Sprint Number"]
    start_date = row["Sprint Start Date"]
    end_date = row["Sprint End Date"]
    team_name = row["Team Name"]
    repo_owner = row["Repository Owner"]
    repo_name = row["Repository Name"]
    git_token = row["Github Access Token"]

    team_names << team_name if team_name

    # Check if team name is present
    if team_name
      # Initialize dictionaries for the team if not already initialized
      repo_owners[team_name] ||= {}
      repo_names[team_name] ||= {}
      access_tokens[team_name] ||= {}

      # Add repository owner, repository name, and GitHub access token to the respective dictionaries
      repo_owners[team_name] = repo_owner if repo_owner
      repo_names[team_name] = repo_name if repo_name
      access_tokens[team_name] = git_token if git_token
    end

    # Check if sprint number, start date, and end date are present
    if sprint_number && start_date && end_date
      # Add start and end dates to the respective dictionaries
      start_dates["start_date_sprint_#{sprint_number.split(' ')[1]}"] = start_date
      end_dates["end_date_sprint_#{sprint_number.split(' ')[1]}"] = end_date
    end
  end

  # Return the dictionaries of start and end dates along with dictionaries of repo owners, repo names, and git tokens
  return start_dates, end_dates, repo_owners, repo_names, access_tokens, team_names
end

start_dates, end_dates, repo_owners, repo_names, access_tokens, team_names  = get_git_info()

# Display the dictionaries and lists
puts "Start Dates:"
puts start_dates["start_date_sprint_1"]
puts "\nEnd Dates:"
end_dates.each { |key, value| puts "#{key}: #{value}" }
puts "\nTeam Names:"

puts team_names
puts "\nRepository Owners:"
puts repo_owners["TAG Team"]
puts "\nRepository Names:"
puts repo_names["TAG Team"]
puts "\nGitHub Access Tokens:"
puts access_tokens["TAG Team"]
