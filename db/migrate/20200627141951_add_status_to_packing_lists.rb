class AddStatusToPackingLists < ActiveRecord::Migration[5.2]
  def change
    add_column :packing_lists, :status, :integer, default: 0
  end
end
