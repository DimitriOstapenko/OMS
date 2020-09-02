class DropColumsFromOrder < ActiveRecord::Migration[5.2]
  def change
    remove_column :orders, :total, :decimal
    remove_column :orders, :weight, :float
    remove_column :orders, :tax, :float
    remove_column :orders, :shipping, :decimal
  end
end
