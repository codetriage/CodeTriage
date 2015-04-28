class RenameCreatorToCreatedByForIssues < ActiveRecord::Migration
  def change
    rename_column :issues, :creator, :created_by
  end
end
