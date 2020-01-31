class AddVatToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :vat, :decimal
  end
end
