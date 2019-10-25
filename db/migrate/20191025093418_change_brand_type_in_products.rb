class ChangeBrandTypeInProducts < ActiveRecord::Migration[5.2]
  def change
     change_column :products, :brand, 'integer USING CAST(brand AS integer)'
  end
end
