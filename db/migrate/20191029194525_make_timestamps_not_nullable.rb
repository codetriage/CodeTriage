class MakeTimestampsNotNullable < ActiveRecord::Migration[6.0]
  def change
    %W[issues repos users doc_methods doc_classes repos repo_subscriptions issue_assignments].each do |table_name|
      change_column_null table_name, :created_at, false, "NOW()"
      change_column_null table_name, :updated_at, false, "NOW()"
    end
  end
end
