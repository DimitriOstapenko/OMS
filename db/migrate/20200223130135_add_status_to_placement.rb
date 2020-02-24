class AddStatusToPlacement < ActiveRecord::Migration[5.2]
  def change
    add_column :placements, :status, :integer
  end
end
