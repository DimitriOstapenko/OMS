class AddDefaultPriceTypeToClients < ActiveRecord::Migration[5.2]
  def change
    change_column :clients, :price_type, :integer, default: 0
  end
end
