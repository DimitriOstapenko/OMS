class AddVisibleToToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :visible_to, :string, array: true, default: []
  end
end
