class AddPriceEu2ColumnToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :price_eu2, :decimal
  end
end
