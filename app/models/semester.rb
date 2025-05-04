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

  # New class method to process static CSV file

  def self.debug_students
    filepath = Rails.root.join('lib', 'assets', 'Students_list.csv')
    students = CSV.read(filepath, headers: true).map { |row| {name: row['Name'], role: row['Role']} }
    puts students.inspect
  end

  # Make sure there's an 'end' for the class itself

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
