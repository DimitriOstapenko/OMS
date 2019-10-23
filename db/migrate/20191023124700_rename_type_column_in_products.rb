class RenameTypeColumnInProducts < ActiveRecord::Migration[5.2]
  def change
    rename_column :products, :prtype, :brand
  end
end
