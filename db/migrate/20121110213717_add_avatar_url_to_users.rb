class AddAvatarUrlToUsers < ActiveRecord::Migration
  def change
    add_column :users, :avatar_url, :string, default: 'http://gravatar.com/avatar/default'
  end
end
