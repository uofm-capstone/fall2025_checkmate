class UserTeam < ApplicationRecord
  belongs_to :user
  belongs_to :team

  validates :user_id, uniqueness: { scope: :team_id, message: "is already a member of this team" }
end
