class AddFieldsToRepositories < ActiveRecord::Migration[6.0]
  def change
    add_column :repositories, :owner, :text
    add_column :repositories, :repo_name, :text
  end
end
