class IndexFullNameOfRepos < ActiveRecord::Migration[5.1]
  def change
    add_index(:repos, [:full_name])
  end
end
