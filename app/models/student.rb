class Student < ApplicationRecord
  has_many :student_teams, dependent: :destroy
  has_many :teams, through: :student_teams
end
