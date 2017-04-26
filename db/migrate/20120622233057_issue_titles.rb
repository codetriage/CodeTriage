class IssueTitles < ActiveRecord::Migration[4.2]
  def change
    add_column :issues, :title, :string
  end
end
