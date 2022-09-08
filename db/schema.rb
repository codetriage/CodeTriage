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

ActiveRecord::Schema.define(version: 2022_09_08_011235) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "pg_stat_statements"
  enable_extension "plpgsql"

  create_table "data_dumps", id: :serial, force: :cascade do |t|
    t.text "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "doc_assignments", id: :serial, force: :cascade do |t|
    t.integer "repo_id"
    t.integer "repo_subscription_id"
    t.integer "doc_method_id"
    t.integer "doc_class_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean "clicked", default: false
    t.index ["repo_id"], name: "index_doc_assignments_on_repo_id"
    t.index ["repo_subscription_id", "doc_method_id"], name: "index_doc_assignments_on_repo_subscription_id_and_doc_method_id"
  end

  create_table "doc_classes", id: :serial, force: :cascade do |t|
    t.integer "repo_id"
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "doc_comments_count", default: 0, null: false
    t.integer "line"
    t.string "path"
    t.string "file"
    t.index ["repo_id", "doc_comments_count"], name: "index_doc_classes_on_repo_id_and_doc_comments_count"
  end

  create_table "doc_comments", id: :serial, force: :cascade do |t|
    t.integer "doc_class_id"
    t.integer "doc_method_id"
    t.text "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["doc_class_id"], name: "index_doc_comments_on_doc_class_id"
    t.index ["doc_method_id"], name: "index_doc_comments_on_doc_method_id"
  end

  create_table "doc_methods", id: :serial, force: :cascade do |t|
    t.integer "repo_id"
    t.string "name"
    t.integer "line"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "doc_comments_count", default: 0, null: false
    t.string "path"
    t.string "file"
    t.boolean "skip_write", default: false
    t.boolean "active", default: true
    t.boolean "skip_read", default: false
    t.boolean "has_comment"
    t.text "comment"
    t.index ["repo_id", "doc_comments_count"], name: "index_doc_methods_on_repo_id_and_doc_comments_count"
    t.index ["repo_id", "id"], name: "index_doc_methods_on_repo_id_and_id"
    t.index ["repo_id", "name", "path"], name: "index_doc_methods_on_repo_id_and_name_and_path", unique: true
  end

  create_table "issue_assignments", id: :serial, force: :cascade do |t|
    t.integer "issue_id"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "repo_subscription_id"
    t.boolean "clicked", default: false
    t.boolean "delivered", default: false
    t.index ["repo_subscription_id", "delivered"], name: "index_issue_assignments_on_repo_subscription_id_and_delivered"
  end

  create_table "issues", id: :serial, force: :cascade do |t|
    t.integer "comment_count"
    t.string "url"
    t.string "repo_name"
    t.string "user_name"
    t.datetime "last_touched_at"
    t.integer "number"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "repo_id"
    t.text "title"
    t.string "html_url"
    t.string "state"
    t.boolean "pr_attached", default: false
    t.index ["number", "repo_id"], name: "index_issues_on_number_and_repo_id", unique: true
    t.index ["repo_id", "id"], name: "index_issues_on_repo_id_and_id", where: "((state)::text = 'open'::text)"
    t.index ["repo_id", "number"], name: "index_issues_on_repo_id_and_number"
    t.index ["repo_id", "state"], name: "index_issues_on_repo_id_and_state"
    t.index ["updated_at"], name: "index_issues_on_updated_at", where: "((state)::text = 'open'::text)"
  end

  create_table "repo_subscriptions", id: :serial, force: :cascade do |t|
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.integer "user_id"
    t.integer "repo_id"
    t.datetime "last_sent_at"
    t.integer "email_limit", default: 1
    t.boolean "write", default: false
    t.boolean "read", default: false
    t.integer "write_limit"
    t.integer "read_limit"
    t.index ["read"], name: "index_repo_subscriptions_on_read"
    t.index ["repo_id", "user_id"], name: "index_repo_subscriptions_on_repo_id_and_user_id"
    t.index ["repo_id"], name: "index_repo_subscriptions_on_repo_id"
    t.index ["user_id", "last_sent_at"], name: "index_repo_subscriptions_on_user_id_and_last_sent_at"
    t.index ["write"], name: "index_repo_subscriptions_on_write"
  end

  create_table "repos", id: :serial, force: :cascade do |t|
    t.string "name"
    t.string "user_name"
    t.integer "issues_count", default: 0, null: false
    t.string "language"
    t.string "description"
    t.string "full_name"
    t.text "notes"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.text "github_error_msg"
    t.string "commit_sha"
    t.integer "stars_count", default: 0
    t.integer "subscribers_count", default: 0
    t.integer "docs_subscriber_count", default: 0
    t.boolean "removed_from_github", default: false
    t.index ["full_name"], name: "index_repos_on_full_name"
    t.index ["issues_count"], name: "index_repos_on_issues_count"
    t.index ["language"], name: "index_repos_on_language"
    t.index ["name", "user_name"], name: "index_repos_on_name_and_user_name", unique: true
    t.index ["user_name"], name: "index_repos_on_user_name"
  end

  create_table "users", id: :serial, force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer "sign_in_count", default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string "current_sign_in_ip"
    t.string "last_sign_in_ip"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.string "zip"
    t.string "phone_number"
    t.boolean "twitter"
    t.string "github"
    t.string "github_access_token"
    t.boolean "admin"
    t.string "avatar_url", default: "http://gravatar.com/avatar/default"
    t.string "name"
    t.boolean "private", default: false
    t.string "favorite_languages", array: true
    t.integer "daily_issue_limit", default: 50
    t.boolean "skip_issues_with_pr", default: false
    t.string "account_delete_token"
    t.datetime "last_clicked_at"
    t.string "email_frequency", default: "daily"
    t.time "email_time_of_day"
    t.string "old_token"
    t.integer "raw_streak_count", default: 0
    t.integer "raw_emails_since_click", default: 0
    t.datetime "last_email_at"
    t.boolean "htos_contributor_unsubscribe", default: false, null: false
    t.boolean "htos_contributor_bought", default: false, null: false
    t.index ["account_delete_token"], name: "index_users_on_account_delete_token"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["github"], name: "index_users_on_github", unique: true
    t.index ["github_access_token"], name: "index_users_on_github_access_token"
    t.index ["private", "id", "created_at"], name: "index_users_on_private_and_id_and_created_at"
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
  end

  add_foreign_key "repo_subscriptions", "repos"
  add_foreign_key "repo_subscriptions", "users"
end
