module ClientScoreHelper  
      include ClientSurveyPatternsHelper
      #      
      # Look at the client_servay_pattern_helper
      #
      
      def calculate_score(matching_row, performance_columns)
        performance_scores = performance_columns.map do |col|
          response = matching_row[col]
          performance_to_score(response)
        end 
      
        # Filter out the scores that are zero
        positive_scores = performance_scores.reject { |score| score.zero? }
      
        # If there are no positive scores (all were zero), return zero or some default value
        return 0.0 if positive_scores.empty?
      
        # Calculate the average from the positive scores only
        performance_average = positive_scores.sum.to_f / positive_scores.size
        performance_average.round(1)
      end
      
      def get_client_score(semester, team, sprint)
        similarity_threshold = 0.1  # Adjust this for team matching as needed
        
        semester.client_csv.open do |tempfile|
          begin
            table = CSV.read(tempfile.path, headers: true)
            performance_columns = table.headers.select { |header| header.match?(PERFORMANCE_PATTERN) }
            sprint_column = table.headers.find { |header| header.match?(SPRINT_PATTERN) }
            team_column = table.headers.find { |header| header.match?(TEAM_PATTERN) }
            
            best_match = nil
            smallest_distance = Float::INFINITY
      
            table.each do |row|
              # First, match sprints exactly to avoid sprint confusion
              next unless row[sprint_column].to_s.strip.downcase == sprint.strip.downcase
      
              # Calculate Levenshtein distance for team names
              team_distance = Levenshtein.distance(row[team_column].to_s.strip.downcase, team.strip.downcase).to_f / [row[team_column].to_s.length, team.length].max
              
              if team_distance < smallest_distance && team_distance < similarity_threshold
                smallest_distance = team_distance
                best_match = row
              end
            end
            
            unless best_match
              Rails.logger.debug "No Matching Row Found for Sprint: #{sprint}"
              return "No Score"
            end
            
            Rails.logger.debug "Best Matching Row Found for Sprint: #{sprint}: #{best_match}"
            performance_average = calculate_score(best_match, performance_columns)
            performance_average
            
          rescue => exception
            Rails.logger.error("Error processing CSV: #{exception.message}")
            "Error! Unable to read sponsor data."
          end    
        end      
      end
end