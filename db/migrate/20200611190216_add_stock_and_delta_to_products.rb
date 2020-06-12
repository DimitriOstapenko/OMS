class AddStockAndDeltaToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :delta, :integer, default: 0
    add_column :products, :stock, :integer, default: 0
  end
end
