class AddInvoiceNumberToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :inv_number, :string
  end
end
