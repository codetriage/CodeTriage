class AddLabelsToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :labels, :string, array:true
  end
end
