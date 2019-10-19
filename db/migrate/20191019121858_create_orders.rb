class CreateOrders < ActiveRecord::Migration[5.2]
  def change
    create_table :orders do |t|
      t.string :order_no
      t.references :product, foreign_key: true
      t.references :client, foreign_key: true
      t.integer :status
      t.string :po_num
      t.decimal :price
      t.integer :pcs
      t.datetime :date

      t.timestamps
    end
  end
end
