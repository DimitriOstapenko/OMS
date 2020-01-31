class AddShippingCostToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :shipping_cost, :float, default: 0.0
  end
end
