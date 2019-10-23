class DropPriceEu2ColumnFromProducts < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :price_eu2, :decimal
  end
end
