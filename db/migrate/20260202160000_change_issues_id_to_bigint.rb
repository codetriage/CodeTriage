# frozen_string_literal: true

class ChangeIssuesIdToBigint < ActiveRecord::Migration[7.0]
  def up
    # Change the id column from integer (serial) to bigint (bigserial)
    # This is necessary because the issues table has exceeded the 32-bit integer limit
    # Max integer: 2,147,483,647
    # Max bigint: 9,223,372,036,854,775,807

    # Primary keys
    change_column :issues, :id, :bigint
    change_column :issue_assignments, :id, :bigint

    # Foreign keys
    change_column :issue_assignments, :issue_id, :bigint
  end

  def down
    # Note: This could fail if there are values > 2,147,483,647
    change_column :issue_assignments, :issue_id, :integer
    change_column :issue_assignments, :id, :integer
    change_column :issues, :id, :integer
  end
end
