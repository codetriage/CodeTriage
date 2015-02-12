class AddSkipMyOwnIssuesAndPrsToUsers < ActiveRecord::Migration
  def change
    add_column :users, :skip_my_own_issues_and_prs, :boolean, default: false
  end
end
