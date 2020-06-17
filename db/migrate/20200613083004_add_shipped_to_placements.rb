class AddShippedToPlacements < ActiveRecord::Migration[5.2]
  def change
    add_column :placements, :shipped, :integer, default: 0
  end
end
