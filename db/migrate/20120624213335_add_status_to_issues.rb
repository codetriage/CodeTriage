class AddStatusToIssues < ActiveRecord::Migration[4.2]
  def change
    add_column :issues, :state, :string
  end
end
