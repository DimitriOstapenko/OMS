class AddTaxToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :tax, :float, default: 0.0
  end
end
