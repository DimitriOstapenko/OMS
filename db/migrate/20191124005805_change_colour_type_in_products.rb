class ChangeColourTypeInProducts < ActiveRecord::Migration[5.2]
  def change
     change_column :products, :colour, 'integer USING CAST(brand AS integer)'
  end
end
