class CreatePackingLists < ActiveRecord::Migration[5.2]
  def change
    create_table :packing_lists do |t|
      t.string :name
      t.text :description
      t.references :user, foreign_key: true

      t.timestamps
    end
  end
end
