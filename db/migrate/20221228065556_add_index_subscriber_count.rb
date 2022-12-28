class AddIndexSubscriberCount < ActiveRecord::Migration[7.0]
  def change
    add_index :repos, :subscribers_count
  end
end
