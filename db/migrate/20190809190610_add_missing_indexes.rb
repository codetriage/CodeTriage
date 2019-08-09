class AddMissingIndexes < ActiveRecord::Migration[5.2]
  disable_ddl_transaction!

  def change
    # users
    add_index(:users, %i[github_access_token], algorithm: :concurrently)
    add_index(:users, %i[private id created_at], algorithm: :concurrently)

    # repo_subscriptions
    add_index(:repo_subscriptions, %i[user_id last_sent_at], algorithm: :concurrently)
    remove_index(:repo_subscriptions, %i[user_id])
    add_index(:repo_subscriptions, %i[repo_id user_id], algorithm: :concurrently)
    remove_index(:repo_subscriptions, %i[repo_id])

    # issue_assignments
    add_index(:issue_assignments, %i[repo_subscription_id created_at], algorithm: :concurrently)
    remove_index(:issue_assignments, %i[repo_subscription_id])
    add_index(:issue_assignments, %i[repo_subscription_id delivered], algorithm: :concurrently)
    remove_index(:issue_assignments, %i[delivered])

    # repos
    remove_index(:repos, %i[name])

    # doc_assignments
    add_index(:doc_assignments, %i[repo_subscription_id doc_method_id], algorithm: :concurrently)
    remove_index(:doc_assignments, %i[repo_subscription_id])

    # doc_methods
    add_index(:doc_methods, %i[repo_id doc_comments_count], algorithm: :concurrently)
    remove_index(:doc_methods, %i[repo_id])

    # doc_classes
    add_index(:doc_classes, %i[repo_id doc_comments_count], algorithm: :concurrently)
    remove_index(:doc_classes, %i[repo_id])

    # issues
    add_index(:issues, %i[repo_id state], algorithm: :concurrently)
    remove_index(:issues, %i[state])
  end
end
