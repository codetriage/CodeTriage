class AddFullNameToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :full_name, :string
  end
end
