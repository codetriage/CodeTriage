class AddFullNameToRepos < ActiveRecord::Migration[4.2]
  def change
    add_column :repos, :full_name, :string unless column_exists?(:repos, :full_name)
  end
end
