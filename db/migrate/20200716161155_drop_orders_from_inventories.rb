class DropOrdersFromInventories < ActiveRecord::Migration[5.2]
  def change
    remove_column :inventories, :orders, :integer
  end
end
