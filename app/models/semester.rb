# app/models/semester.rb
require 'csv'
class Semester < ApplicationRecord
  has_one_attached :student_csv
  has_one_attached :git_csv
  has_one_attached :client_csv

  belongs_to :user
  has_many :sprints, inverse_of: :semester, dependent: :destroy
  has_many :teams, inverse_of: :semester, dependent: :destroy
  has_many :repositories, dependent: :nullify
  accepts_nested_attributes_for :sprints, allow_destroy: true, reject_if: :all_blank

  validates :semester, presence: true, inclusion: { in: %w[Fall Spring Summer] }
  validates :semester, uniqueness: { scope: :year, message: "Semester and year combination already exists" }
  validates :year, presence: true

  # To create default sprint when new semester is created.
  after_create :create_default_sprints

  # Existing method
  def name_for_select
    "#{semester} #{year}"
  end

  # Find the current active semester based on the current date
  def self.current_active
    current_date = Date.current
    current_year = current_date.year

    # Define semester date ranges
    spring_range = Date.new(current_year, 1, 1)..Date.new(current_year, 5, 31)
    summer_range = Date.new(current_year, 6, 1)..Date.new(current_year, 7, 31)
    fall_range = Date.new(current_year, 8, 1)..Date.new(current_year, 12, 31)

    # Determine current semester based on date
    current_semester = case current_date
                      when spring_range then 'Spring'
                      when summer_range then 'Summer'
                      when fall_range then 'Fall'
                      end

    # Find the semester record
    semester = where(semester: current_semester, year: current_year).first

    # If no semester exists for the current period, return the most recent semester
    semester || order(year: :desc, semester: :desc).first
  end

  # New class method to process static CSV file
  def self.debug_students
    filepath = Rails.root.join('lib', 'assets', 'Students_list.csv')
    students = CSV.read(filepath, headers: true).map { |row| {name: row['Name'], role: row['Role']} }
    puts students.inspect
  end

  def create_teams_from_csv
    # It is possible for there to be same team names but different semester/year
    # Do not need to check other semester's teams, so putting it in model instead of getTeams method (controller)
    return unless student_csv.attached?

    # Extract existing semester's team names to avoid duplicates
    existing_team_names = teams.pluck(:name)

    # Process the CSV
    student_csv.open do |tempfile|
      begin
        data = SmarterCSV.process(tempfile.path)

        # Remove header rows
        data.delete_at(0) if data[0]
        data.delete_at(0) if data[0]

        # Extract team names
        team_names = data.map { |row| row[:q2] }.compact.uniq

        # Create teams that don't already exist
        team_names.each do |team_name|
          next if team_name.blank? || existing_team_names.include?(team_name)
          teams.create!(name: team_name)
        end
      # In case it fails
      rescue => e
        Rails.logger.error("Error creating teams from CSV: #{e.message}")
        false
      end
    end
    true
  end


  private

  def create_default_sprints
    # Create four default sprints with sequential names and dates
    start_date = Date.new(self.year.to_i, 1, 30)  # Starting with Jan 30th of the year

    4.times do |i|
      # Each sprint is roughly a month
      end_date = start_date + 28.days

      self.sprints.create!(
        name: "Sprint #{i+1}",
        start_date: start_date,
        end_date: end_date
      )

      # Set start date for next sprint
      start_date = end_date + 1.day
    end
  end

end
