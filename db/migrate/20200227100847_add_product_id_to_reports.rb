class AddProductIdToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :product_id, :integer
  end
end
