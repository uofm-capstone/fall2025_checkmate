class Team < ApplicationRecord
  belongs_to :semester
  has_many :student_teams, dependent: :destroy
  has_many :students, through: :student_teams

  validates :name, presence: true
  # Possible for there to be multiple same team name - go by semester
  validates :name, uniqueness: { scope: :semester_id, message: "already exists for this semester" }

end
