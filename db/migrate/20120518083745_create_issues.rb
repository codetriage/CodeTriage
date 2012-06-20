class CreateIssues < ActiveRecord::Migration
  def change
    create_table :issues do |t|
      t.integer   :comment_count
      t.string    :url, :repo_name, :user_name
      t.datetime  :last_touched_at
      t.integer   :number

      t.timestamps
    end
  end
end
