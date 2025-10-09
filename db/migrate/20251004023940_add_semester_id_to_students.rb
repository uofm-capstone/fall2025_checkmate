class AddSemesterIdToStudents < ActiveRecord::Migration[7.0]
  def change
    add_reference :students, :semester, foreign_key: true
  end
end
