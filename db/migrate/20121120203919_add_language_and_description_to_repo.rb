class AddLanguageAndDescriptionToRepo < ActiveRecord::Migration
  def change
    add_column :repos, :language, :string unless column_exists?(:repos, :language)
    add_column :repos, :description, :string unless column_exists?(:repos, :description)
  end
end
