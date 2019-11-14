class AddPriceEu2ToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :price_eu2, :decimal, default: 0
  end
end
