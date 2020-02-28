class AddColumnsToPpos < ActiveRecord::Migration[5.2]
  def change
    add_column :ppos, :orders, :integer, default: 0
    add_column :ppos, :pcs, :integer, default: 0
  end
end
