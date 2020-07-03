class Add2ColumnsToPlacements < ActiveRecord::Migration[5.2]
  def change
    add_column :placements, :to_ship, :integer, default: 0
    add_column :placements, :last_pl_id, :integer
  end
end
