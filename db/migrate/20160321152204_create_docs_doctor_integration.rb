class CreateDocsDoctorIntegration < ActiveRecord::Migration[5.0]
  def change
    create_table "doc_assignments", force: :cascade do |t|
      t.integer  "repo_id"
      t.integer  "repo_subscription_id"
      t.integer  "user_id"
      t.integer  "doc_method_id"
      t.integer  "doc_class_id"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "doc_assignments", ["repo_id"], name: "index_doc_assignments_on_repo_id", using: :btree
    add_index "doc_assignments", ["repo_subscription_id"], name: "index_doc_assignments_on_repo_subscription_id", using: :btree
    add_index "doc_assignments", ["user_id"], name: "index_doc_assignments_on_user_id", using: :btree

    create_table "doc_classes", force: :cascade do |t|
      t.integer  "repo_id"
      t.string   "name"
      t.datetime "created_at"
      t.datetime "updated_at"
      t.integer  "doc_comments_count", default: 0, null: false
      t.integer  "line"
      t.string   "path"
      t.string   "file"
    end

    add_index "doc_classes", ["repo_id"], name: "index_doc_classes_on_repo_id", using: :btree

    create_table "doc_comments", force: :cascade do |t|
      t.integer  "doc_class_id"
      t.integer  "doc_method_id"
      t.text     "comment"
      t.datetime "created_at"
      t.datetime "updated_at"
    end

    add_index "doc_comments", ["doc_class_id"], name: "index_doc_comments_on_doc_class_id", using: :btree
    add_index "doc_comments", ["doc_method_id"], name: "index_doc_comments_on_doc_method_id", using: :btree

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
    end

    add_index "doc_methods", ["repo_id"], name: "index_doc_methods_on_repo_id", using: :btree

    add_column :repo_subscriptions, :write, :boolean, default: false
    add_column :repo_subscriptions, :read,  :boolean, default: false

    add_column :repo_subscriptions, :write_limit,  :integer
    add_column :repo_subscriptions, :read_limit,   :integer

    add_column :repos, :commit_sha, :string
  end
end
