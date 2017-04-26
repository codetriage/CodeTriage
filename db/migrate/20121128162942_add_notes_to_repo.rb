class AddNotesToRepo < ActiveRecord::Migration[4.2]
  def change
    add_column :repos, :notes, :text unless column_exists?(:repos, :notes)
  end
end
