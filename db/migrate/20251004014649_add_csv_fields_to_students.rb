class AddCSVFieldsToStudents < ActiveRecord::Migration[7.0]
  def change
    # email already exists
    add_column :students, :project_board_url, :string
    add_column :students, :timesheet_url, :string
    add_column :students, :client_notes_url, :string
  end
end
