class AddRemovedFromGithubToRepo < ActiveRecord::Migration[6.0]
  def change
    add_column :repos, :removed_from_github, :boolean, default: false
  end
end
