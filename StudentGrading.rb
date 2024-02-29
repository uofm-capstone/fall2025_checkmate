require 'csv'

# Converts a survey response to a numerical score based on your specified grading scale
def convert_response_to_score(response)
  case response.downcase
  when 'always'
    5.0
  when 'most of the time'
    4.0
  when 'about half of the time'
    3.0
  when 'sometimes'
    2.0
  when 'never'
    0.0
  else
    nil # Handles invalid responses by returning nil, which we'll exclude from scoring
  end
end

# Reads the CSV data and processes each row to calculate scores for each student
def process_csv_data(file_path)
  student_scores = Hash.new { |hash, key| hash[key] = [] }

  CSV.foreach(file_path, headers: true) do |row|
    students_info = {
      row['Q1'] => (1..6).map { |i| "Q11_#{i}" }, # Student self
      row['Q10'] => (1..6).map { |i| "Q21_#{i}" }, # Teammate #1
      row['Q13'] => (1..6).map { |i| "Q15_#{i}" }, # Teammate #2
      row['Q23'] => (1..6).map { |i| "Q16_#{i}" }, # Teammate #3
      row['Q24'] => (1..6).map { |i| "Q25_#{i}" }, # Teammate #4
    }.reject { |key, _| key.nil? || key.strip.empty? } # Remove any entries without a name

    students_info.each do |name, questions|
      questions.each do |question|
        if row.headers.include?(question) && !row[question].nil?
          response = row[question]
          score = convert_response_to_score(response)
          student_scores[name] << score unless score.nil?
        end
      end
    end
  end

  student_scores
end

# Calculates the average score for each student
def calculate_averages(student_scores)
  averages = {}

  student_scores.each do |student, scores|
    averages[student] = {
      average_score: scores.sum / scores.size.to_f,
      # Assuming the first score is the self-assessment, which we exclude for the excluding_self calculation
      average_score_excluding_self: scores[1..-1].empty? ? 0 : scores[1..-1].sum / (scores.size - 1).to_f
    }
  end

  averages
end

# Main execution block
begin
  csv_file_path = 'student_survey.csv' # Update this path with your actual CSV file path
  student_scores = process_csv_data(csv_file_path)
  averages = calculate_averages(student_scores)

  # Output the results
  averages.each do |student, scores|
    puts "Student: #{student}, Average Score: #{scores[:average_score]}, Average Score Excluding Self: #{scores[:average_score_excluding_self]}"
  end
rescue StandardError => e
  puts "An error occurred: #{e.message}"
end
