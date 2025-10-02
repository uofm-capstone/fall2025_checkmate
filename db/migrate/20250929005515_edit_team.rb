class EditTeam < ActiveRecord::Migration[7.0]
  def change
    add_column :teams, :repo_url, :string
    add_column :teams, :timesheet_url, :string
    add_column :teams, :project_board_url, :string
    add_column :teams, :client_notes_url, :string
  end
end
