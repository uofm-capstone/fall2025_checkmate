class DropUserTeams < ActiveRecord::Migration[7.0]
  def change
    drop_table :user_teams do |t|
      t.references :user, null: false, foreign_key: true
      t.references :team, null: false, foreign_key: true
      t.timestamps
    end
  end
end
