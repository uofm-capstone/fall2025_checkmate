class AddTeamToRepositories < ActiveRecord::Migration[6.0]
  def change
    add_column :repositories, :team, :text
  end
end
