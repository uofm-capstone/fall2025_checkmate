# == Schema Information
#
# Table name: semesters
#
#  id         :bigint           not null, primary key
#  semester   :string
#  year       :integer
#  created_at :datetime         not null
#  updated_at :datetime         not null
#
class Semester < ApplicationRecord

    has_one_attached :student_csv
    has_one_attached :client_csv
    

    has_many :sprints, inverse_of: :semester
    accepts_nested_attributes_for :sprints, allow_destroy: true, reject_if: :all_blank

    validates :semester, presence: true
    validates :semester, inclusion: { in: %w[Fall Spring Summer] }
    validates :year, presence: true
end
