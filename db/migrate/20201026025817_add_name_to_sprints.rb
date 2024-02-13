class AddNameToSprints < ActiveRecord::Migration[6.0]
  def change
    add_column :sprints, :name, :text
  end
end
