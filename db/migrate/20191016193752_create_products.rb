class CreateProducts < ActiveRecord::Migration[5.2]
  def change
    create_table :products do |t|
      t.string :name
      t.string :prtype
      t.string :category
      t.string :description
      t.string :colour
      t.integer :scale
      t.date :release_date
      t.decimal :price_eu
      t.decimal :price_usd

      t.timestamps
    end
  end
end
