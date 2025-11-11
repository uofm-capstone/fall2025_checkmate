class AddCommitCountToRepositories < ActiveRecord::Migration[7.0]
  def change
    add_column :repositories, :commit_count, :integer
  end
end
