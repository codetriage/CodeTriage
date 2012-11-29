class AddNotesToRepo < ActiveRecord::Migration
  def change
    add_column :repos, :notes, :text
  end
end
