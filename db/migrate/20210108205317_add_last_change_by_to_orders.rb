class AddLastChangeByToOrders < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :last_change_by, :string
  end
end
