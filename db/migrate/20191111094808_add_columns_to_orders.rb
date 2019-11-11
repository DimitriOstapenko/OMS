class AddColumnsToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :web_id, :string
    add_column :orders, :status, :integer, default: 0
  end
end
