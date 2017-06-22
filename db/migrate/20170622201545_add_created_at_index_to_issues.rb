class AddCreatedAtIndexToIssues < ActiveRecord::Migration[5.1]
  def change
    add_index :issues, :created_at, where: "state = '#{Issue::OPEN}'"
  end
end
