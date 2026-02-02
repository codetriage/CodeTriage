# frozen_string_literal: true

class ChangeIssuesIdToBigint < ActiveRecord::Migration[7.0]
  # Disable transaction to allow running on large tables without locking for too long
  # You may want to run this during low-traffic periods
  disable_ddl_transaction!

  def up
    # Change the id column from integer (serial) to bigint (bigserial)
    # This is necessary because the issues table has exceeded the 32-bit integer limit
    # Max integer: 2,147,483,647
    # Max bigint: 9,223,372,036,854,775,807

    safety_assured do
      # Change the primary key column type
      execute "ALTER TABLE issues ALTER COLUMN id TYPE bigint"

      # Change the sequence type to bigint as well
      execute "ALTER SEQUENCE issues_id_seq AS bigint"

      # Also update foreign keys in issue_assignments that reference issues.id
      execute "ALTER TABLE issue_assignments ALTER COLUMN issue_id TYPE bigint"
    end
  end

  def down
    safety_assured do
      # Note: This could fail if there are values > 2,147,483,647
      execute "ALTER TABLE issue_assignments ALTER COLUMN issue_id TYPE integer"
      execute "ALTER SEQUENCE issues_id_seq AS integer"
      execute "ALTER TABLE issues ALTER COLUMN id TYPE integer"
    end
  end
end
