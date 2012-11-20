class AddLanguageAndDescriptionToRepo < ActiveRecord::Migration
  def change
    add_column :repos, :language, :string
    add_column :repos, :description, :string
  end
end
