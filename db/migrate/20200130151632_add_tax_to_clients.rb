class AddTaxToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :tax_pc, :float, default: 0
  end
end
