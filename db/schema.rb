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

ActiveRecord::Schema.define(version: 20140710164307) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "issue_assignments", force: true do |t|
    t.integer  "issue_id"
    t.datetime "created_at",                           null: false
    t.datetime "updated_at",                           null: false
    t.integer  "repo_subscription_id"
    t.boolean  "clicked",              default: false
    t.boolean  "delivered",            default: false
  end

  add_index "issue_assignments", ["delivered"], name: "index_issue_assignments_on_delivered", using: :btree

  create_table "issues", force: true do |t|
    t.integer  "comment_count"
    t.string   "url"
    t.string   "repo_name"
    t.string   "user_name"
    t.datetime "last_touched_at"
    t.integer  "number"
    t.datetime "created_at",                      null: false
    t.datetime "updated_at",                      null: false
    t.integer  "repo_id"
    t.string   "title"
    t.string   "html_url"
    t.string   "state"
    t.boolean  "pr_attached",     default: false
  end

  create_table "opro_auth_grants", force: true do |t|
    t.string   "code"
    t.string   "access_token"
    t.string   "refresh_token"
    t.text     "permissions"
    t.datetime "access_token_expires_at"
    t.integer  "user_id"
    t.integer  "application_id"
    t.datetime "created_at",              null: false
    t.datetime "updated_at",              null: false
  end

  create_table "opro_client_apps", force: true do |t|
    t.string   "name"
    t.string   "app_id"
    t.string   "app_secret"
    t.text     "permissions"
    t.integer  "user_id"
    t.datetime "created_at",  null: false
    t.datetime "updated_at",  null: false
  end

  create_table "repo_subscriptions", force: true do |t|
    t.string   "user_name"
    t.string   "repo_name"
    t.datetime "created_at",               null: false
    t.datetime "updated_at",               null: false
    t.integer  "user_id"
    t.integer  "repo_id"
    t.datetime "last_sent_at"
    t.integer  "email_limit",  default: 1
  end

  create_table "repos", force: true do |t|
    t.string   "name"
    t.string   "user_name"
    t.datetime "created_at",                   null: false
    t.datetime "updated_at",                   null: false
    t.integer  "issues_count",     default: 0, null: false
    t.string   "language"
    t.string   "description"
    t.string   "full_name"
    t.text     "notes"
    t.text     "github_error_msg"
  end

  create_table "users", force: true do |t|
    t.string   "email",                  default: "",                                   null: false
    t.string   "encrypted_password",     default: "",                                   null: false
    t.string   "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip"
    t.string   "last_sign_in_ip"
    t.datetime "created_at",                                                            null: false
    t.datetime "updated_at",                                                            null: false
    t.string   "zip"
    t.string   "phone_number"
    t.boolean  "twitter"
    t.string   "github"
    t.string   "github_access_token"
    t.boolean  "admin"
    t.string   "name"
    t.string   "avatar_url",             default: "http://gravatar.com/avatar/default"
    t.boolean  "private",                default: false
    t.string   "favorite_languages",                                                                 array: true
    t.integer  "daily_issue_limit"
    t.boolean  "skip_issues_with_pr",    default: false
    t.string   "account_delete_token"
    t.datetime "last_clicked_at"
  end

  add_index "users", ["account_delete_token"], name: "index_users_on_account_delete_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["github"], name: "index_users_on_github", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
