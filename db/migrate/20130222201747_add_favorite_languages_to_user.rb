class AddFavoriteLanguagesToUser < ActiveRecord::Migration
  def change
    add_column :users, :favorite_languages, :string_array
  end
end
