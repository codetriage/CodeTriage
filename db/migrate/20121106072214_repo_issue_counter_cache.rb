class RepoIssueCounterCache < ActiveRecord::Migration
  def up
    add_column :repos, :issues_count, :integer, :default => 0, :null => false

    Repo.reset_column_information
    Repo.find_each do |repo|
      repo.issues_count = repo.issues.where(state: 'open').count
      repo.save
    end
  end

  def down
    remove_column :repos, :issues_count
  end
end
