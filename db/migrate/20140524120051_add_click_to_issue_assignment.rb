class AddClickToIssueAssignment < ActiveRecord::Migration[4.2]
  def change
    add_column :issue_assignments, :clicked,         :boolean,  default: false
    add_column :users,             :last_clicked_at, :timestamp
    User.find_each(&:save)
  end
end
