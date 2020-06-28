class AddOrdersAndProductsToPackingList < ActiveRecord::Migration[5.2]
  def change
    add_column :packing_lists, :orders, :integer, default: 0
    add_column :packing_lists, :products, :integer, default: 0
  end
end
