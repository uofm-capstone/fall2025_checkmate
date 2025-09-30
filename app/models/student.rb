class Student < ApplicationRecord
  belongs_to :team, optional: true   

  validates :full_name, presence: true
  validates :email, presence: true, format: { with: URI::MailTo::EMAIL_REGEXP }
  validates :github_username, presence: true
  validates :github_username, uniqueness: { scope: :team_id, message: "already exists for this team" }
end
