class CreateLoves < ActiveRecord::Migration[5.0]
  def change
    create_table :loves, id: :uuid do |t|
      t.string :url
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
