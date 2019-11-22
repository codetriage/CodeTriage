class AddCommentToDocMethod < ActiveRecord::Migration[6.0]
  def change
    add_column :doc_methods, :has_comment, :boolean, index: true
    add_column :doc_methods, :comment, :text
  end
end
