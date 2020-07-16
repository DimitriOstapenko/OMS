class AddCsvToInventories < ActiveRecord::Migration[5.2]
  def change
    add_column :inventories, :csv, :string
  end
end
