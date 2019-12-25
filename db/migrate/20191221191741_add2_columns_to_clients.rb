class Add2ColumnsToClients < ActiveRecord::Migration[5.2]
  def change
    add_column :clients, :default_terms, :integer, default: 0
    add_column :clients, :pref_delivery_by, :integer, default: 0
  end
end
