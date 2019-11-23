class CreatePrices < ActiveRecord::Migration[5.2]
  def change
    create_table :prices do |t|
      t.integer :scale, default: 18
      t.decimal :price_eu
      t.decimal :price_eu2
      t.decimal :price_usd

      t.timestamps
    end
  end
end
