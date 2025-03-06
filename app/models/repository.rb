# == Schema Information
#
# Table name: repositories
#
#  id         :bigint           not null, primary key
#  owner      :text
#  repo_name  :text
#  team       :text
#  created_at :datetime         not null
#  updated_at :datetime         not null
#  user_id    :bigint           not null
#
# Indexes
#
#  index_repositories_on_user_id  (user_id)
#
# Foreign Keys
#
#  fk_rails_...  (user_id => users.id)
#
class Repository < ApplicationRecord
    validates :owner, presence: true
    validates :repo_name, presence: true
    validates :team, presence: true

    belongs_to :user,
        class_name: 'User',
        foreign_key: 'user_id',
        inverse_of: :repositories

    # Add relationship to semester
    belongs_to :semester, optional: true

end
