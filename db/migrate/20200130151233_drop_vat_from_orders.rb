class DropVatFromOrders < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :vat, :string
  end
end
