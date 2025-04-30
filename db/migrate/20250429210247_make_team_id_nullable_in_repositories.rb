class MakeTeamIdNullableInRepositories < ActiveRecord::Migration[7.0]
  def change
    change_column_null :repositories, :team_id, true
  end
end
