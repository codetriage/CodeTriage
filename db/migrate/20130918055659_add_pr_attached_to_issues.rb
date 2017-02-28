class AddPrAttachedToIssues < ActiveRecord::Migration[4.2]
  def change
    add_column :issues, :pr_attached, :boolean, default: false
  end
end
