class AddFullNameToRepos < ActiveRecord::Migration
  def change
    add_column :repos, :full_name, :string unless column_exists?(:repos, :full_name)
  end
end
