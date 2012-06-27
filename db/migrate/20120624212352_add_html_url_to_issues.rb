class AddHtmlUrlToIssues < ActiveRecord::Migration
  def change
    add_column :issues, :html_url, :string
  end
end
