# app/models/student.rb
class Student < ApplicationRecord
  # Associations
  belongs_to :semester, optional: true  # Students belong to a semester
  has_many :student_teams, dependent: :destroy
  has_many :teams, through: :student_teams

  alias_attribute :name, :full_name
  
  # Validations
  validates :full_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :email, uniqueness: { scope: :semester_id, message: "already exists for this semester" }, allow_blank: true
  validates :github_username, length: { maximum: 100 }, allow_blank: true
  validates :project_board_url, :timesheet_url, :client_notes_url,
            format: { with: /\Ahttps?:\/\/[\S]+\z/, message: "must be a valid URL" },
            allow_blank: true
end
