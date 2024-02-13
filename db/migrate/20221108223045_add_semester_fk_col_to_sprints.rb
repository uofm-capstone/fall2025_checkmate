class AddSemesterFkColToSprints < ActiveRecord::Migration[6.0]
  def change
    add_reference :sprints, :semester, foreign_key: true
  end
end
