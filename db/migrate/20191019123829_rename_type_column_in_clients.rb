class RenameTypeColumnInClients < ActiveRecord::Migration[5.2]
  def change
     rename_column :clients, :type, :cltype
  end
end
