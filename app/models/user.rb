# == Schema Information
#
# Table name: users
#
#  id                     :bigint           not null, primary key
#  email                  :string           default(""), not null
#  encrypted_password     :string           default(""), not null
#  github_token           :string
#  remember_created_at    :datetime
#  reset_password_sent_at :datetime
#  reset_password_token   :string
#  created_at             :datetime         not null
#  updated_at             :datetime         not null
#
# Indexes
#
#  index_users_on_email                 (email) UNIQUE
#  index_users_on_reset_password_token  (reset_password_token) UNIQUE
#
class User < ApplicationRecord
  # Define roles
  enum role: { guest: 0, student: 1, ta: 2, admin: 3 }, _default: :guest

  validates :email, presence: true, format: { with: /\A[^@\s]+@[^@\s]+\z/, message: "Must be a valid email address" }
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable

  # In this version (version_1), each user has only one (implied) class,
  # And each user directly owns repositories and sprints
  has_many :semester, dependent: :destroy
  has_many :repositories,
  class_name: 'Repository',
  foreign_key: 'user_id',
  inverse_of: :user,
  dependent: :destroy

  # Joint table with Team
  # has_many :user_teams, dependent: :destroy
  # has_many :teams, through: :user_teams


  # For backward compatibility with existing admin boolean
  def admin?
    role == "admin" || self[:admin] == true
  end
end
