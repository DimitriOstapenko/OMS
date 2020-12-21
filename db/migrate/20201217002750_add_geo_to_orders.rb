class AddGeoToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :geo, :integer, default: 0
  end
end
