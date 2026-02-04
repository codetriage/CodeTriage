# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[8.1].define(version: 2026_02_02_163145) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_catalog.plpgsql"
  enable_extension "pg_stat_statements"

  create_table "data_dumps", force: :cascade do |t|
    t.datetime "created_at", precision: nil
    t.text "data"
    t.datetime "updated_at", precision: nil
  end

  create_table "doc_assignments", force: :cascade do |t|
    t.boolean "clicked", default: false
    t.datetime "created_at", precision: nil
    t.bigint "doc_class_id"
    t.bigint "doc_method_id"
    t.bigint "repo_id"
    t.bigint "repo_subscription_id"
    t.datetime "updated_at", precision: nil
    t.index ["repo_id"], name: "index_doc_assignments_on_repo_id"
    t.index ["repo_subscription_id", "doc_method_id"], name: "index_doc_assignments_on_repo_subscription_id_and_doc_method_id"
  end

  create_table "doc_classes", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "doc_comments_count", default: 0, null: false
    t.string "file"
    t.integer "line"
    t.string "name"
    t.string "path"
    t.bigint "repo_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["repo_id", "doc_comments_count"], name: "index_doc_classes_on_repo_id_and_doc_comments_count"
  end

  create_table "doc_comments", force: :cascade do |t|
    t.text "comment"
    t.datetime "created_at", precision: nil
    t.bigint "doc_class_id"
    t.bigint "doc_method_id"
    t.datetime "updated_at", precision: nil
    t.index ["doc_class_id"], name: "index_doc_comments_on_doc_class_id"
    t.index ["doc_method_id"], name: "index_doc_comments_on_doc_method_id"
  end

  create_table "doc_methods", force: :cascade do |t|
    t.boolean "active", default: true
    t.text "comment"
    t.datetime "created_at", precision: nil, null: false
    t.integer "doc_comments_count", default: 0, null: false
    t.string "file"
    t.boolean "has_comment"
    t.integer "line"
    t.string "name"
    t.string "path"
    t.bigint "repo_id"
    t.boolean "skip_read", default: false
    t.boolean "skip_write", default: false
    t.datetime "updated_at", precision: nil, null: false
    t.index ["repo_id", "doc_comments_count"], name: "index_doc_methods_on_repo_id_and_doc_comments_count"
    t.index ["repo_id", "id"], name: "index_doc_methods_on_repo_id_and_id"
    t.index ["repo_id", "name", "path"], name: "index_doc_methods_on_repo_id_and_name_and_path", unique: true
  end

  create_table "issue_assignments", force: :cascade do |t|
    t.boolean "clicked", default: false
    t.datetime "created_at", precision: nil, null: false
    t.boolean "delivered", default: false
    t.bigint "issue_id"
    t.bigint "repo_subscription_id"
    t.datetime "updated_at", precision: nil, null: false
    t.index ["repo_subscription_id", "delivered"], name: "index_issue_assignments_on_repo_subscription_id_and_delivered"
  end

  create_table "issues", force: :cascade do |t|
    t.integer "comment_count"
    t.datetime "created_at", precision: nil, null: false
    t.string "html_url"
    t.datetime "last_touched_at", precision: nil
    t.integer "number"
    t.boolean "pr_attached", default: false
    t.bigint "repo_id"
    t.string "repo_name"
    t.string "state"
    t.text "title"
    t.datetime "updated_at", precision: nil, null: false
    t.string "url"
    t.string "user_name"
    t.index ["number", "repo_id"], name: "index_issues_on_number_and_repo_id", unique: true
    t.index ["repo_id", "id"], name: "index_issues_on_repo_id_and_id", where: "((state)::text = 'open'::text)"
    t.index ["repo_id", "number"], name: "index_issues_on_repo_id_and_number"
    t.index ["repo_id", "state"], name: "index_issues_on_repo_id_and_state"
    t.index ["updated_at"], name: "index_issues_on_updated_at", where: "((state)::text = 'open'::text)"
  end

  create_table "labels", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.string "name", null: false
    t.datetime "updated_at", null: false
  end

  create_table "repo_labels", force: :cascade do |t|
    t.datetime "created_at", null: false
    t.bigint "label_id", null: false
    t.bigint "repo_id", null: false
    t.datetime "updated_at", null: false
    t.index ["label_id"], name: "index_repo_labels_on_label_id"
    t.index ["repo_id", "label_id"], name: "index_repo_labels_on_repo_id_and_label_id", unique: true
    t.index ["repo_id"], name: "index_repo_labels_on_repo_id"
  end

  create_table "repo_subscriptions", force: :cascade do |t|
    t.datetime "created_at", precision: nil, null: false
    t.integer "email_limit", default: 1
    t.datetime "last_sent_at", precision: nil
    t.boolean "read", default: false
    t.integer "read_limit"
    t.bigint "repo_id"
    t.datetime "updated_at", precision: nil, null: false
    t.bigint "user_id"
    t.boolean "write", default: false
    t.integer "write_limit"
    t.index ["read"], name: "index_repo_subscriptions_on_read"
    t.index ["repo_id", "user_id"], name: "index_repo_subscriptions_on_repo_id_and_user_id"
    t.index ["repo_id"], name: "index_repo_subscriptions_on_repo_id"
    t.index ["user_id", "last_sent_at"], name: "index_repo_subscriptions_on_user_id_and_last_sent_at"
    t.index ["write"], name: "index_repo_subscriptions_on_write"
  end

  create_table "repos", force: :cascade do |t|
    t.boolean "archived", default: false
    t.string "commit_sha"
    t.datetime "created_at", precision: nil, null: false
    t.string "description"
    t.integer "docs_subscriber_count", default: 0
    t.string "full_name"
    t.text "github_error_msg"
    t.integer "issues_count", default: 0, null: false
    t.string "language"
    t.string "name"
    t.text "notes"
    t.boolean "removed_from_github", default: false
    t.integer "stars_count", default: 0
    t.integer "subscribers_count", default: 0
    t.datetime "updated_at", precision: nil, null: false
    t.string "user_name"
    t.index ["archived"], name: "index_repos_on_archived"
    t.index ["full_name"], name: "index_repos_on_full_name"
    t.index ["issues_count"], name: "index_repos_on_issues_count"
    t.index ["language"], name: "index_repos_on_language"
    t.index ["name", "user_name"], name: "index_repos_on_name_and_user_name", unique: true
    t.index ["subscribers_count"], name: "index_repos_on_subscribers_count"
    t.index ["user_name"], name: "index_repos_on_user_name"
  end

  create_table "users", force: :cascade do |t|
    t.string "account_delete_token"
    t.boolean "admin"
    t.string "avatar_url", default: "http://gravatar.com/avatar/default"
    t.datetime "created_at", precision: nil, null: false
    t.datetime "current_sign_in_at", precision: nil
    t.string "current_sign_in_ip"
    t.integer "daily_issue_limit", default: 50
    t.string "email", default: "", null: false
    t.string "email_frequency", default: "daily"
    t.time "email_time_of_day"
    t.string "encrypted_password", default: "", null: false
    t.string "favorite_languages", array: true
    t.string "github"
    t.string "github_access_token"
    t.boolean "htos_contributor_bought", default: false, null: false
    t.boolean "htos_contributor_unsubscribe", default: false, null: false
    t.datetime "last_clicked_at", precision: nil
    t.datetime "last_email_at", precision: nil
    t.datetime "last_sign_in_at", precision: nil
    t.string "last_sign_in_ip"
    t.string "name"
    t.string "old_token"
    t.string "phone_number"
    t.boolean "private", default: false
    t.integer "raw_emails_since_click", default: 0
    t.integer "raw_streak_count", default: 0
    t.datetime "remember_created_at", precision: nil
    t.datetime "reset_password_sent_at", precision: nil
    t.string "reset_password_token"
    t.integer "sign_in_count", default: 0
    t.boolean "skip_issues_with_pr", default: false
    t.boolean "twitter"
    t.datetime "updated_at", precision: nil, null: false
    t.string "zip"
    t.index ["account_delete_token"], name: "index_users_on_account_delete_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["github"], name: "index_users_on_github", unique: true
    t.index ["github_access_token"], name: "index_users_on_github_access_token"
    t.index ["private", "id", "created_at"], name: "index_users_on_private_and_id_and_created_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "repo_labels", "labels"
  add_foreign_key "repo_labels", "repos"
  add_foreign_key "repo_subscriptions", "repos"
  add_foreign_key "repo_subscriptions", "users"
end
