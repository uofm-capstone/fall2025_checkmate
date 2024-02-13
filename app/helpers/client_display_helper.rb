module ClientDisplayHelper
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