class AddCnyToPrices < ActiveRecord::Migration[5.2]
  def change
    add_column :prices, :price_cny, :decimal
  end
end
