class AddFieldsToStudents < ActiveRecord::Migration[7.0]
  def change
    add_column :students, :full_name, :string
    add_column :students, :email, :string
    add_column :students, :github_username, :string
    add_column :students, :team_name, :string
  end
end
