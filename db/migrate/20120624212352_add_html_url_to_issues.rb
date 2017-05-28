class AddHtmlUrlToIssues < ActiveRecord::Migration[4.2]
  def change
    add_column :issues, :html_url, :string
  end
end
