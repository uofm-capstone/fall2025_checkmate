class AddUniqueIndexToSemesters < ActiveRecord::Migration[7.0]
  def change
    # Adding so that semester/year is unique
    add_index :semesters, [:semester, :year], unique: true
  end
end
