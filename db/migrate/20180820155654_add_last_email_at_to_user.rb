class AddLastEmailAtToUser < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :last_email_at, :datetime
  end
end
