class AddAvatarUrlToUsers < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :avatar_url, :string, default: 'http://gravatar.com/avatar/default'
  end
end
