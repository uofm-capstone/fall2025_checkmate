class CreateRepos < ActiveRecord::Migration[7.0]
  def change
    create_table :repos do |t|
      t.string :name
      t.integer :commit_count

      t.timestamps
    end
  end
end
