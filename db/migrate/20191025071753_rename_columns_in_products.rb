class RenameColumnsInProducts < ActiveRecord::Migration[5.2]
  def change
    rename_column :products, :description, :notes
    rename_column :products, :name, :description
    rename_column :products, :added, :added_date
  end
end
