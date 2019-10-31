class AddQuantityToPlacements < ActiveRecord::Migration[5.2]
  def change
    add_column :placements, :quantity, :integer, default: 0
  end
end
