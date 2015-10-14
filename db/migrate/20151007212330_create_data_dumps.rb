class CreateDataDumps < ActiveRecord::Migration
  def change
    create_table :data_dumps do |t|
      t.text :data
      t.timestamps
    end
  end
end
