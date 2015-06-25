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

ActiveRecord::Schema.define(version: 20150211235706) do

  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "issue_assignments", force: :cascade do |t|
    t.integer  "issue_id"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "repo_subscription_id"
    t.boolean  "clicked",              default: false
    t.boolean  "delivered",            default: false
  end

  add_index "issue_assignments", ["delivered"], name: "index_issue_assignments_on_delivered", using: :btree

  create_table "issues", force: :cascade do |t|
    t.integer  "comment_count"
    t.string   "url",             limit: 255
    t.string   "repo_name",       limit: 255
    t.string   "user_name",       limit: 255
    t.datetime "last_touched_at"
    t.integer  "number"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "repo_id"
    t.string   "title",           limit: 255
    t.string   "html_url",        limit: 255
    t.string   "state",           limit: 255
    t.boolean  "pr_attached",                 default: false
    t.string   "created_by"
  end

  create_table "repo_subscriptions", force: :cascade do |t|
    t.string   "user_name",    limit: 255
    t.string   "repo_name",    limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.integer  "user_id"
    t.integer  "repo_id"
    t.datetime "last_sent_at"
    t.integer  "email_limit",              default: 1
  end

  create_table "repos", force: :cascade do |t|
    t.string   "name",             limit: 255
    t.string   "user_name",        limit: 255
    t.integer  "issues_count",                 default: 0, null: false
    t.string   "language",         limit: 255
    t.string   "description",      limit: 255
    t.string   "full_name",        limit: 255
    t.text     "notes"
    t.datetime "created_at"
    t.datetime "updated_at"
    t.text     "github_error_msg"
  end

  create_table "users", force: :cascade do |t|
    t.string   "email",                      limit: 255, default: "",                                   null: false
    t.string   "encrypted_password",         limit: 255, default: "",                                   null: false
    t.string   "reset_password_token",       limit: 255
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.integer  "sign_in_count",                          default: 0
    t.datetime "current_sign_in_at"
    t.datetime "last_sign_in_at"
    t.string   "current_sign_in_ip",         limit: 255
    t.string   "last_sign_in_ip",            limit: 255
    t.datetime "created_at"
    t.datetime "updated_at"
    t.string   "zip",                        limit: 255
    t.string   "phone_number",               limit: 255
    t.boolean  "twitter"
    t.string   "github",                     limit: 255
    t.string   "github_access_token",        limit: 255
    t.boolean  "admin"
    t.string   "avatar_url",                 limit: 255, default: "http://gravatar.com/avatar/default"
    t.string   "name",                       limit: 255
    t.boolean  "private",                                default: false
    t.string   "favorite_languages",                                                                                 array: true
    t.integer  "daily_issue_limit"
    t.boolean  "skip_issues_with_pr",                    default: false
    t.string   "account_delete_token",       limit: 255
    t.datetime "last_clicked_at"
    t.boolean  "skip_my_own_issues_and_prs",             default: false
  end

  add_index "users", ["account_delete_token"], name: "index_users_on_account_delete_token", using: :btree
  add_index "users", ["email"], name: "index_users_on_email", unique: true, using: :btree
  add_index "users", ["github"], name: "index_users_on_github", unique: true, using: :btree
  add_index "users", ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true, using: :btree

end
