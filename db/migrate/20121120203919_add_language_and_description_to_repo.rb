class AddLanguageAndDescriptionToRepo < ActiveRecord::Migration[4.2]
  def change
    add_column :repos, :language, :string unless column_exists?(:repos, :language)
    add_column :repos, :description, :string unless column_exists?(:repos, :description)
  end
end
