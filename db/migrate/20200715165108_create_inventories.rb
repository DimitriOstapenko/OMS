class CreateInventories < ActiveRecord::Migration[5.2]
  def change
    create_table :inventories do |t|
      t.string :name
      t.string :description
      t.integer :lines
      t.integer :orders
      t.integer :products
      t.integer :pcs
      t.integer :uploaded_by
      t.integer :status
      t.string :md5

      t.timestamps
    end
  end
end
