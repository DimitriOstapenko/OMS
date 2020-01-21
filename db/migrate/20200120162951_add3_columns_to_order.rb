class Add3ColumnsToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :pmt_method, :integer, default: 1
    add_column :orders, :shipping, :decimal, default: 0
    add_column :orders, :discount, :decimal, default: 0
  end
end
