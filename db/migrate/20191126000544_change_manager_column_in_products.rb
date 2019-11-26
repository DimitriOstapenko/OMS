class ChangeManagerColumnInProducts < ActiveRecord::Migration[5.2]
  def change
    change_column :products, :manager, 'integer USING CAST(manager AS integer)' 
  end
end
