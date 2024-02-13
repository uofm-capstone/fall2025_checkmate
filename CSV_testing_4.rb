require 'csv'
require 'logger'
# Define a method to check if a header matches the desired patterns
def header_matches?(header, pattern)
  header.match?(pattern)
end

# Patterns
SPRINT_PATTERN = /\AQ3\z/i
TEAM_PATTERN = /\AQ1_TEAM\z/i
CLIENT_PATTERN = /\AQ1\z/i
GENERAL_PATTERN = /\Aq(_?\d+|\d+(_\d+)?)\z/i
PERFORMANCE_PATTERN = /\Aq2_\d+\z/i

# Convert performance responses to scores
def performance_to_score(response)
    response = response.to_s.downcase
    #puts "List::::#{response}"
  
    case response
    when "exceeded expectations" then 3.0
    when "met expectations" then 2.0
    when "did not meet expectations" then 1.0
    when "" then 0.0
    else
      puts "Invalid response: #{response}"
      0.0
    end
  end
  

def filter_csv
  file_path = 'working client 4 sprints.csv'

  table = CSV.read(file_path, headers: true)

  # Filter out the undesired row
  table.delete_if do |row|
    row.fields.any? { |field| field.to_s.strip.start_with?('{"ImportId"') }
  end

  # Select the relevant columns based on the header pattern
  sprint_columns = table.headers.select { |header| header_matches?(header, SPRINT_PATTERN) }
  team_columns = table.headers.select { |header| header_matches?(header, TEAM_PATTERN) }
  client_columns = table.headers.select { |header| header_matches?(header, CLIENT_PATTERN) }
  general_columns = table.headers.select { |header| header_matches?(header, GENERAL_PATTERN) }
  performance_columns = table.headers.select { |header| header_matches?(header, PERFORMANCE_PATTERN) }

  puts "\nSprint:"
  puts sprint_columns.join(", ")

  puts "\nTeams:"
  puts team_columns.join(", ")

  puts "\nClient:"
  puts client_columns.join(", ")

  puts "\nPerformance Questions:"
  puts performance_columns.join(", ")

  puts "\nGeneral Questions:"
  puts (general_columns - performance_columns - sprint_columns - client_columns - team_columns).join(", ")

 

  table.each do |row|
    puts "\n--- New Entry ---"

    puts "\nSprint:"
    selected_data = row.to_h.select { |header, _| sprint_columns.include?(header) }
    puts selected_data.values.join(", ")

    puts "\nTeam:"
    selected_data = row.to_h.select { |header, _| team_columns.include?(header) }
    puts selected_data.values.join(", ")

    puts "\nClient:"
    selected_data = row.to_h.select { |header, _| client_columns.include?(header) }
    puts selected_data.values.join(", ")

    puts "\nPerformance Questions:"
    selected_data = row.to_h.select { |header, _| performance_columns.include?(header) }
    puts selected_data.values.join(", ")

    # Calculate and print performance score
    performance_score = selected_data.values.map { |response| performance_to_score(response) }.sum / 6
    puts "Performance Score (max 3): #{performance_score.round(2)}"

    

    puts "\nGeneral Questions:"
    selected_data = row.to_h.select { |header, _| (general_columns - performance_columns - sprint_columns - client_columns - team_columns).include?(header) }
    puts selected_data.values.join(", ")
  end

  
end

filter_csv
