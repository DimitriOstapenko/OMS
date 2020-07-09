class AddProductToClients < ActiveRecord::Migration[5.2]
  def change
    add_reference :clients, :product, foreign_key: true
  end
end
