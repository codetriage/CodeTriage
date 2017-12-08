class AddSubscribersCountToRepos < ActiveRecord::Migration[5.1]
  def change
    add_column :repos, :subscribers_count, :integer, default: 0
    Repo.reset_column_information
    Repo.find_each do |p|
      Repo.reset_counters p.id, :subscribers_count
    end
  end
end
