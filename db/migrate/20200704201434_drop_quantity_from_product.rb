class DropQuantityFromProduct < ActiveRecord::Migration[5.2]
  def change
    remove_column :products, :quantity, :integer
  end
end
