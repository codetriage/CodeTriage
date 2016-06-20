class ChangeIssuesTitleToText < ActiveRecord::Migration[5.0]
  def up
    change_column :issues, :title, :text
  end

  def down
    change_column :issues, :title, :string, limit: 255
  end
end
