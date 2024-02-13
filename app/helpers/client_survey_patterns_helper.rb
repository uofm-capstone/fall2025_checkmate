module ClientSurveyPatternsHelper

    #This helper is assigned to help keep all the hardcoded values for the cleint CSV in one place 


    SPRINT_PATTERN = /\Aq3\z/i
    TEAM_PATTERN = /\Aq1_team\z/i
    PERFORMANCE_PATTERN = /\Aq2_\d+\z/i
    CLIENT_EVALUATION  = [/\Aq7\z/i,/\Aq4\z/i,/\Aq5\z/i,/\Aq6\z/i]

    #there is another hardcoded data inside the team.html.erb:
    #<% expected_keys = ['q2_1', 'q2_2', 'q2_3', 'q2_4', 'q2_5', 'q2_6'].map(&:to_sym) %>

    #there is another one in the client_display_helper.rb
    #  def extract_full_questions(csv_path)
    #       csv = CSV.read(csv_path, headers: true)
    #       question_headers = csv.headers.grep(/\Aq2_\d+\z/i)
    #       full_questions = csv[0].values_at(*question_headers)
    #       Hash[question_headers.zip(full_questions)]
    #       end


    #client_display_helper.rb 
        #next if client_survey[:q1_team].blank? || client_survey[:q1_team].start_with?('{')
        #next if client_survey[:q3].blank?

        #similarities = compare_strings(team, client_survey[:q1_team])

        #best_matching_team = client_survey[:q1_team]

        #cliSurvey = client_data_raw.find_all { |survey| survey[:q1_team] == best_matching_team && survey[:q3] == sprint }
        


    #used by the client_score_helper
    def performance_to_score(response)
        response = response.to_s.downcase
        case response
        when "exceeded expectations" then 3.0
        when "met expectations" then 2.0
        when "did not meet expectations" then 1.0
        when "" then 0.0
        else 0.0
        end
    end
end