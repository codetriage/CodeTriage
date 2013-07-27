class AddNotesToRepo < ActiveRecord::Migration
  def change
    add_column :repos, :notes, :text unless column_exists?(:repos, :notes)
  end
end
