require 'csv'

def convert_response_to_score(response)
  return nil if response.nil? # Return nil immediately if the response is nil

  case response.downcase
  when 'always' then 5.0
  when 'most of the time' then 4.0
  when 'about half of the time' then 3.0
  when 'sometimes' then 2.0
  when 'never' then 0.0
  else nil # Handles invalid or missing responses by returning nil
  end
end

def process_csv_data(file_path)
  # Organizing data by team and then by sprint for each student
  team_sprint_scores = Hash.new do |h, team|
    h[team] = Hash.new do |h2, sprint|
      h2[sprint] = Hash.new { |h3, student| h3[student] = {self_scores: [], peer_scores: []} }
    end
  end

  CSV.foreach(file_path, headers: true) do |row|
    team = row['Q2']
    sprint = row['Q22']
    student_name = row['Q1']
    add_scores(team_sprint_scores, team, sprint, student_name, row)
  end

  team_sprint_scores
end

def add_scores(team_sprint_scores, team, sprint, student_name, row)
  # Assuming a similar pattern for scores as previously described
  # Adjust the question prefixes and ranges according to your survey structure
  (1..6).each do |i|
    self_score = convert_response_to_score(row["Q11_#{i}"])
    team_sprint_scores[team][sprint][student_name][:self_scores] << self_score unless self_score.nil?

    # Example for Teammate #1 assessments
    peer_score = convert_response_to_score(row["Q21_#{i}"])
    team_sprint_scores[team][sprint][student_name][:peer_scores] << peer_score unless peer_score.nil?
  end
end

def calculate_averages(team_sprint_scores)
  team_sprint_scores.each do |team, sprints|
    sprints.each do |sprint, students|
      students.each do |student, scores|
        all_scores = scores[:self_scores] + scores[:peer_scores]
        all_scores_compact = all_scores.compact
        peer_scores_compact = scores[:peer_scores].compact

        students[student][:average_score] = calculate_average(all_scores_compact)
        students[student][:average_score_excluding_self] = calculate_average(peer_scores_compact)
      end
    end
  end
end

def calculate_average(scores)
  return "*Did not submit survey*" if scores.empty?
  (scores.sum.to_f / scores.size).round(1)
end

# Main execution block
begin
  csv_file_path = 'student_survey.csv' # Update this path with your actual CSV file path
  team_sprint_scores = process_csv_data(csv_file_path)
  calculate_averages(team_sprint_scores)

  # Output the results
  team_sprint_scores.each do |team, sprints|
    puts "Team: #{team}"
    sprints.each do |sprint, students|
      puts "  Sprint: #{sprint}"
      students.each do |student, scores|
        puts "    Student: #{student}, Average Score: #{scores[:average_score]}, Average Score Excluding Self: #{scores[:average_score_excluding_self]}"
      end
    end
  end
rescue StandardError => e
  puts "An error occurred: #{e.message}"
end
