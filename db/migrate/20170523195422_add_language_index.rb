class AddLanguageIndex < ActiveRecord::Migration[5.0]
  def change
    add_index :repos, :language
  end
end
