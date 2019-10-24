class AddFieldsToProduct < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :added, :date
    add_column :products, :supplier, :string
    add_column :products, :manager, :string
    add_column :products, :progress, :integer
  end
end
