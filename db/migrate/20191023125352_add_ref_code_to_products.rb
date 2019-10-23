class AddRefCodeToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :ref_code, :string
    add_index :products, :ref_code
  end
end
