class AddCtnsToProducts < ActiveRecord::Migration[5.2]
  def change
    add_column :products, :ctns, :integer
  end
end
