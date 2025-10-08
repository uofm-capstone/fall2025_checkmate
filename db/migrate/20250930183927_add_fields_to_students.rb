class AddFieldsToStudents < ActiveRecord::Migration[7.0]
  def change
    change_table :students do |t|
      t.string :full_name unless column_exists?(:students, :full_name)
      t.string :email unless column_exists?(:students, :email)
      t.string :github_username unless column_exists?(:students, :github_username)
      t.string :team_name unless column_exists?(:students, :team_name)
    end
  end
end
