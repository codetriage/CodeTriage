class AddUpdatedAtIndexToIssues < ActiveRecord::Migration[6.0]
  def change
    add_index :issues, :updated_at, where: "state = '#{Issue::OPEN}'"
  end
end
