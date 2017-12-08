class AddPartialIndexToId < ActiveRecord::Migration[5.1]
  def change
    add_index(:issues, :id, where: "state = '#{Issue::OPEN}'")
  end
end
