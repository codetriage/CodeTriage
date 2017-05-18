class AddDelieveredToIssueAssignment < ActiveRecord::Migration[4.2]
  def change
    add_column :issue_assignments, :delivered, :boolean, {default: false}
    # add_index  :users, :github, unique: true
    add_index :issue_assignments, :delivered

    ::IssueAssignment.find_each do |assignment|
      assignment.delivered = true if assignment.respond_to?(:delivered)
    end
  end
end
