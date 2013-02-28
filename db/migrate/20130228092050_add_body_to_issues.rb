class AddBodyToIssues < ActiveRecord::Migration
  def change
  	add_column :issues, :body, :text
  end
end
