class CreateRepos < ActiveRecord::Migration
  def change
    create_table :repos do |t|
      t.string   "name"
      t.string   "user_name"
      t.integer  "issues_count", default: 0, null: false
      t.string   "language"
      t.string   "description"
      t.string   "full_name"
      t.text     "notes"

      t.timestamps
    end
  end
end
