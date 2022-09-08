class AddHtosPromoToUser < ActiveRecord::Migration[6.1]
  def change
    add_column :users, :htos_contributor_unsubscribe, :boolean, default: false, null: false
    add_column :users, :htos_contributor_bought, :boolean, default: false, null: false
  end
end
