class AddPriceColumsToPrices < ActiveRecord::Migration[5.2]
  def change
    add_column :prices, :price_usd2, :decimal
    add_column :prices, :price_eu3, :decimal
    add_column :prices, :price_eu4, :decimal
    add_column :prices, :price_eu5, :decimal
    add_column :prices, :price_eu6, :decimal
  end
end
