class AddPriceColumsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :price_usd2, :decimal, default: 0
    add_column :products, :price_eu3, :decimal, default: 0
    add_column :products, :price_eu4, :decimal, default: 0
    add_column :products, :price_eu5, :decimal, default: 0
    add_column :products, :price_eu6, :decimal, default: 0
  end
end
