class ChangeDeliveryByTypeInOrders < ActiveRecord::Migration[5.2]
  def change
    change_column :orders, :delivery_by, :string
  end
end
