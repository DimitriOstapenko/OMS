class AddPriceTypeToClient < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :price_type, :integer
  end
end
