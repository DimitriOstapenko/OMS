class AddLinesAndPcsToPackingList < ActiveRecord::Migration[5.2]
  def change
    add_column :packing_lists, :lines, :integer, default: 0
    add_column :packing_lists, :pcs, :integer, default: 0
  end
end
