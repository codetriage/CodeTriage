class AddCreatorToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :creator, :string
  end
end
