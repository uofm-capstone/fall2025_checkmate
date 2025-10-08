class Student < ActiveRecord::Migration[7.0]
  def change
    change_table :students, bulk: true do |t|
      t.string  :full_name unless column_exists?(:students, :full_name)
      t.string  :email unless column_exists?(:students, :email)
      t.string  :github_username unless column_exists?(:students, :github_username)
      t.integer :team_id unless column_exists?(:students, :team_id)
    end

    add_index :students, [:team_id, :github_username], unique: true,
      name: "index_students_on_team_id_and_github_username" \
      unless index_exists?(:students, [:team_id, :github_username], unique: true)
  end
end
