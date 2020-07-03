class AddMd5ToPackingLists < ActiveRecord::Migration[5.2]
  def change
    add_column :packing_lists, :md5, :string
  end
end
