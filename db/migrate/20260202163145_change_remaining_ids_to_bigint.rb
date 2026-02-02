# frozen_string_literal: true

class ChangeRemainingIdsToBigint < ActiveRecord::Migration[7.0]
  def up
    # Change remaining id columns from integer (serial) to bigint (bigserial)
    # Max integer: 2,147,483,647
    # Max bigint: 9,223,372,036,854,775,807

    # Primary keys
    change_column :data_dumps, :id, :bigint
    change_column :doc_assignments, :id, :bigint
    change_column :doc_classes, :id, :bigint
    change_column :doc_comments, :id, :bigint
    change_column :doc_methods, :id, :bigint
    change_column :repo_subscriptions, :id, :bigint
    change_column :repos, :id, :bigint
    change_column :users, :id, :bigint

    # Foreign keys
    change_column :doc_assignments, :repo_id, :bigint
    change_column :doc_assignments, :repo_subscription_id, :bigint
    change_column :doc_assignments, :doc_method_id, :bigint
    change_column :doc_assignments, :doc_class_id, :bigint
    change_column :doc_classes, :repo_id, :bigint
    change_column :doc_comments, :doc_class_id, :bigint
    change_column :doc_comments, :doc_method_id, :bigint
    change_column :doc_methods, :repo_id, :bigint
    change_column :issue_assignments, :repo_subscription_id, :bigint
    change_column :issues, :repo_id, :bigint
    change_column :repo_subscriptions, :user_id, :bigint
    change_column :repo_subscriptions, :repo_id, :bigint
  end

  def down
    # Note: This could fail if there are values > 2,147,483,647

    # Foreign keys
    change_column :repo_subscriptions, :repo_id, :integer
    change_column :repo_subscriptions, :user_id, :integer
    change_column :issues, :repo_id, :integer
    change_column :issue_assignments, :repo_subscription_id, :integer
    change_column :doc_methods, :repo_id, :integer
    change_column :doc_comments, :doc_method_id, :integer
    change_column :doc_comments, :doc_class_id, :integer
    change_column :doc_classes, :repo_id, :integer
    change_column :doc_assignments, :doc_class_id, :integer
    change_column :doc_assignments, :doc_method_id, :integer
    change_column :doc_assignments, :repo_subscription_id, :integer
    change_column :doc_assignments, :repo_id, :integer

    # Primary keys
    change_column :users, :id, :integer
    change_column :repos, :id, :integer
    change_column :repo_subscriptions, :id, :integer
    change_column :doc_methods, :id, :integer
    change_column :doc_comments, :id, :integer
    change_column :doc_classes, :id, :integer
    change_column :doc_assignments, :id, :integer
    change_column :data_dumps, :id, :integer
  end
end
