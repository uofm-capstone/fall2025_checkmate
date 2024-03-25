require 'csv'

def get_sprint_dates()
  # Read CSV data from the file
  csv = CSV.read('/Users/naitik/Downloads/Github Info.csv', headers: true)

  # Initialize dictionaries to hold start and end dates for each sprint
  start_dates = {}
  end_dates = {}

  # Iterate over each row in the CSV data
  csv.each do |row|
    sprint_number = row["Sprint Number"]
    start_date = row["Sprint Start Date"]
    end_date = row["Sprint End Date"]

    # Check if sprint number, start date, and end date are present
    if sprint_number && start_date && end_date
      # Add start and end dates to the respective dictionaries
      start_dates["start_date_sprint_#{sprint_number.split(' ')[1]}"] = start_date
      end_dates["end_date_sprint_#{sprint_number.split(' ')[1]}"] = end_date
    end
  end

  # Return the dictionaries of start and end dates
  return start_dates, end_dates
end

start_dates, end_dates = get_sprint_dates()

# Display the dictionaries
puts "Start Dates:"
puts start_dates["start_date_sprint_1"]
puts "\nEnd Dates:"
end_dates.each { |key, value| puts "#{key}: #{value}" }
