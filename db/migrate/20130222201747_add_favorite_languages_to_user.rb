class AddFavoriteLanguagesToUser < ActiveRecord::Migration
  def change
    add_column :users, :favorite_languages, :string, array: true
  end
end
