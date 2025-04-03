class Team < ApplicationRecord
  belongs_to :semester
  has_many :user_teams, dependent: :destroy
  has_many :users, through: :user_teams
  has_many :repositories, dependent: :nullify

  validates :name, presence: true
  # Possible for there to be multiple same team name - go by semester
  validates :name, uniqueness: { scope: :semester_id, message: "already exists for this semester" }

end
