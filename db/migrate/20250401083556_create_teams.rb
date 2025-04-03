class CreateTeams < ActiveRecord::Migration[7.0]
  def change
    create_table :teams do |t|
      t.string :name
      t.text :description
      t.references :semester, null: false, foreign_key: true
      t.string :github_token

      t.timestamps
    end
  end
end
