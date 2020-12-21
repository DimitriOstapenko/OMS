class AddGeoToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :geo, :integer, default: 0
  end
end
