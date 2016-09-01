class AddStarsCountToRepos < ActiveRecord::Migration[5.0]
  def change
    add_column :repos, :stars_count, :integer, default: 0
  end
end
