class AddPriceToPlacement < ActiveRecord::Migration[5.2]
  def change
    add_column :placements, :price, :decimal
  end
end
