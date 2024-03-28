class AddDescriptionToSemesters < ActiveRecord::Migration[7.0]
  def change
    add_column :semesters, :description, :string
  end
end
