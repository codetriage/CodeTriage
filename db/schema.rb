# encoding: UTF-8
# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema.define(version: 20160606060546) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"
  enable_extension "pg_stat_statements"

  create_table "data_dumps", force: :cascade do |t|
    t.text     "data"
    t.datetime "created_at"
    t.datetime "updated_at"
  end

  create_table "doc_assignments", force: :cascade do |t|
    t.integer  "repo_id"
    t.integer  "repo_subscription_id"
    t.integer  "doc_method_id"
    t.integer  "doc_class_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.boolean  "clicked",              default: false
    t.index ["repo_id"], name: "index_doc_assignments_on_repo_id", using: :btree
    t.index ["repo_subscription_id"], name: "index_doc_assignments_on_repo_subscription_id", using: :btree
  end

  create_table "doc_classes", force: :cascade do |t|
    t.integer  "repo_id"
    t.string   "name"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "doc_comments_count", default: 0, null: false
    t.integer  "line"
    t.string   "path"
    t.string   "file"
    t.index ["repo_id"], name: "index_doc_classes_on_repo_id", using: :btree
  end

  create_table "doc_comments", force: :cascade do |t|
    t.integer  "doc_class_id"
    t.integer  "doc_method_id"
    t.text     "comment"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.index ["doc_class_id"], name: "index_doc_comments_on_doc_class_id", using: :btree
    t.index ["doc_method_id"], name: "index_doc_comments_on_doc_method_id", using: :btree
  end

  create_table "doc_methods", force: :cascade do |t|
    t.integer  "repo_id"
    t.string   "name"
    t.integer  "line"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "doc_comments_count", default: 0,     null: false
    t.string   "path"
    t.string   "file"
    t.boolean  "skip_write",         default: false
    t.boolean  "active",             default: true
    t.boolean  "skip_read",          default: false
    t.index ["repo_id"], name: "index_doc_methods_on_repo_id", using: :btree
  end

  create_table "issue_assignments", force: :cascade do |t|
    t.integer  "issue_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "repo_subscription_id"
    t.boolean  "clicked",              default: false
    t.boolean  "delivered",            default: false
    t.index ["delivered"], name: "index_issue_assignments_on_delivered", using: :btree
  end

  create_table "issues", force: :cascade do |t|
    t.integer  "comment_count"
    t.string   "url",             limit: 255
    t.string   "repo_name",       limit: 255
    t.string   "user_name",       limit: 255
    t.datetime "last_touched_at"
    t.integer  "number"
    t.datetime "created_at",                                  null: false
    t.datetime "updated_at",                                  null: false
    t.integer  "repo_id"
    t.string   "title",           limit: 255
    t.string   "html_url",        limit: 255
    t.string   "state",           limit: 255
    t.boolean  "pr_attached",                 default: false
    t.index ["number"], name: "index_issues_on_number", using: :btree
    t.index ["repo_id"], name: "index_issues_on_repo_id", using: :btree
    t.index ["state"], name: "index_issues_on_state", using: :btree
  end

  create_table "opro_auth_grants", force: :cascade do |t|
    t.string   "code",                    limit: 255
    t.string   "access_token",            limit: 255
    t.string   "refresh_token",           limit: 255
    t.text     "permissions"
    t.datetime "access_token_expires_at"
    t.integer  "user_id"
    t.integer  "application_id"
    t.datetime "created_at",                          null: false
    t.datetime "updated_at",                          null: false
  end

  create_table "opro_client_apps", force: :cascade do |t|
    t.string   "name",        limit: 255
    t.string   "app_id",      limit: 255
    t.string   "app_secret",  limit: 255
    t.text     "permissions"
    t.integer  "user_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "repo_subscriptions", force: :cascade do |t|
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "user_id"
    t.integer  "repo_id"
    t.datetime "last_sent_at"
    t.integer  "email_limit",  default: 1
    t.boolean  "write",        default: false
    t.boolean  "read",         default: false
    t.integer  "write_limit"
    t.integer  "read_limit"
  end

  create_table "repos", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "user_name",        limit: 255
    t.datetime "created_at",                               null: false
    t.datetime "updated_at",                               null: false
    t.integer  "issues_count",                 default: 0, null: false
    t.string   "language",         limit: 255
    t.string   "description",      limit: 255
    t.string   "full_name",        limit: 255
    t.text     "notes"
    t.text     "github_error_msg"
    t.string   "commit_sha"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                  limit: 255, default: "",                                   null: false
    t.string   "encrypted_password",     limit: 255, default: "",                                   null: false
    t.string   "reset_password_token",   limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                      default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",     limit: 255
    t.string   "last_sign_in_ip",        limit: 255
    t.datetime "created_at",                                                                        null: false
    t.datetime "updated_at",                                                                        null: false
    t.string   "zip",                    limit: 255
    t.string   "phone_number",           limit: 255
    t.boolean  "twitter"
    t.string   "github",                 limit: 255
    t.string   "github_access_token",    limit: 255
    t.boolean  "admin"
    t.string   "name",                   limit: 255
    t.string   "avatar_url",             limit: 255, default: "http://gravatar.com/avatar/default"
    t.boolean  "private",                            default: false
    t.string   "favorite_languages",                                                                             array: true
    t.integer  "daily_issue_limit"
    t.boolean  "skip_issues_with_pr",                default: false
    t.string   "account_delete_token",   limit: 255
    t.datetime "last_clicked_at"
    t.string   "email_frequency"
    t.index ["account_delete_token"], name: "index_users_on_account_delete_token", using: :btree
    t.index ["email"], name: "index_users_on_email", unique: true, using: :btree
    t.index ["github"], name: "index_users_on_github", unique: true, using: :btree
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree
  end

end
