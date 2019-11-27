class AddCategoryColumnToPrice < ActiveRecord::Migration[5.2]
  def change
    add_column :prices, :category, :integer
  end
end
