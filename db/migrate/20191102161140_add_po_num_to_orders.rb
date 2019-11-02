class AddPoNumToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :po_number, :string
  end
end
