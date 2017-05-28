class CreateDataDumps < ActiveRecord::Migration[4.2]
  def change
    create_table :data_dumps do |t|
      t.text :data
      t.timestamps
    end
  end
end
