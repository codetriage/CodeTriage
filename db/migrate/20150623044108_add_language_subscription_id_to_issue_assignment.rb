class AddLanguageSubscriptionIdToIssueAssignment < ActiveRecord::Migration
  def change
    add_column :issue_assignments, :language_subscription_id, :integer
  end
end
