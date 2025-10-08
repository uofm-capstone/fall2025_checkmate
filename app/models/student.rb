class Student < ApplicationRecord
  belongs_to :team, optional: true
  validates :full_name, :email, :github_username, :team_name, presence: true
  
  has_many :student_teams, dependent: :destroy
  has_many :teams, through: :student_teams
end
