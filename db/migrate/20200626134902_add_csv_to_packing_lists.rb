class AddCsvToPackingLists < ActiveRecord::Migration[5.2]
  def change
    add_column :packing_lists, :csv, :string
  end
end
