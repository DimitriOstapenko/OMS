class AddManualPriceToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :manual_price, :boolean, default: false
  end
end
