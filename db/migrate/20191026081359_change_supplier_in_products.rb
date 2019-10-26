class ChangeSupplierInProducts < ActiveRecord::Migration[5.2]
  def change
    change_column :products, :supplier, 'integer USING CAST(brand AS integer)'
  end
end
