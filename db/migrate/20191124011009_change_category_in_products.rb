class ChangeCategoryInProducts < ActiveRecord::Migration[5.2]
  def change
    change_column :products, :category, 'integer USING CAST(brand AS integer)'
  end
end
