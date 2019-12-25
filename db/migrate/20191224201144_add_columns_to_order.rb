class AddColumnsToOrder < ActiveRecord::Migration[5.2]
  def change
    add_column :orders, :terms, :integer
    add_column :orders, :delivery_by, :integer
  end
end
