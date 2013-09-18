class AddPrAttachedToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :pr_attached, :boolean, default: false
  end
end
