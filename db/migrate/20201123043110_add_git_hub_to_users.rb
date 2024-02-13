class AddGitHubToUsers < ActiveRecord::Migration[6.0]
  def change
    add_column :users, :github_token, :string
  end
end
