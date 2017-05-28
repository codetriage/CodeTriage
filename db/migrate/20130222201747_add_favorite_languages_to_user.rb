class AddFavoriteLanguagesToUser < ActiveRecord::Migration[4.2]
  def change
    add_column :users, :favorite_languages, :string, array: true
  end
end
