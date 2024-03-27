module ClientDisplayHelper

    def get_git_info()
      # Read CSV data from the file
      csv = CSV.read('Github Info.csv', headers: true)

      # Initialize dictionaries to hold start and end dates for each sprint
      start_dates = {}
      end_dates = {}

      # Initialize dictionaries for repo owners, repo names, and GitHub access tokens indexed by team names
      repo_owners = {}
      repo_names = {}
      access_tokens = {}
      team_names = []
      sprint_numbers = []

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
        sprint_numbers << sprint_number if sprint_number

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

          start_dates["Sprint #{sprint_number.split(' ')[1]}"] = start_dates["start_date_sprint_#{sprint_number.split(' ')[1]}"]
          end_dates["Sprint #{sprint_number.split(' ')[1]}"] =  end_dates["end_date_sprint_#{sprint_number.split(' ')[1]}"]
        end
      end

      # Return the dictionaries of start and end dates along with dictionaries of repo owners, repo names, and git tokens
      return start_dates, end_dates, team_names, repo_owners, repo_names, access_tokens, sprint_numbers
    end

    def process_client_data(semester, team, sprint)
      client_data = {}
      flags = []

      begin
        semester.client_csv.open do |tempClient|
          client_data_raw = SmarterCSV.process(tempClient.path)
          full_questions = extract_full_questions(tempClient.path)

          @client_question_titles = client_data_raw[0].select { |key, _| key.to_s.start_with?('q') }


          max_similarity = 0
          best_matching_team = nil

          client_data_raw.each do |client_survey|

            next if client_survey[:q1_team].blank? || client_survey[:q1_team].start_with?('{')
            next if client_survey[:q3].blank?

            similarities = compare_strings(team, client_survey[:q1_team])
            avg_similarity = (similarities[:jaro_winkler] + similarities[:levenshtein]) / 2.0

            if avg_similarity > max_similarity
              max_similarity = avg_similarity
              best_matching_team = client_survey[:q1_team]
            end
          end

          cliSurvey = client_data_raw.find_all { |survey| survey[:q1_team] == best_matching_team && survey[:q3] == sprint }
          cliSurvey.map! { |survey| survey.select { |key, _| key.to_s.start_with?('q') } }


          if cliSurvey.blank?
            flags.append("client blank")
          end

          client_data = {
            full_questions: full_questions,
            cliSurvey: cliSurvey
          }
        end
      rescue => e
        Rails.logger.debug("DEBUG: Exception processing client CSV: #{e}")
        flags.append("client csv error")
      end

      [client_data, flags]
    end

    private

    #helps display the questions from the second roll in the CSV
    def extract_full_questions(csv_path)
      csv = CSV.read(csv_path, headers: true)
      question_headers = csv.headers.grep(/\Aq2_\d+\z/i)
      full_questions = csv[0].values_at(*question_headers)
      Hash[question_headers.zip(full_questions)]
    end




end
