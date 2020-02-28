class DropUniqueIndexFromPpos < ActiveRecord::Migration[5.2]
  def change
    remove_index :ppos, :product_id
    add_index :ppos, :product_id
  end
end
