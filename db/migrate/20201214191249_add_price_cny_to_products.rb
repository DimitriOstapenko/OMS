class AddPriceCnyToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :price_cny, :decimal, default: 0.0
  end
end
