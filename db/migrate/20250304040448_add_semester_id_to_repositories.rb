class AddSemesterIdToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_reference :repositories, :semester, foreign_key: true, index: true
  end
end
