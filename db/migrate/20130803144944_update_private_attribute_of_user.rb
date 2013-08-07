class UpdatePrivateAttributeOfUser < ActiveRecord::Migration
  def change
    change_column :users, :private, :boolean, default: false
    # Update existing users. Set :private to false if it is nil
    User.where(private: nil).find_each do |u|
      u.private = false
      u.save!
    end
  end
end
