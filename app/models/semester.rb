# app/models/semester.rb
require 'csv'
class Semester < ApplicationRecord
    has_one_attached :student_csv
    has_one_attached :client_csv
    has_one_attached :git_csv

    belongs_to :user
    has_many :sprints, inverse_of: :semester
    accepts_nested_attributes_for :sprints, allow_destroy: true, reject_if: :all_blank

    validates :semester, presence: true, inclusion: { in: %w[Fall Spring Summer] }
    validates :year, presence: true

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
end
