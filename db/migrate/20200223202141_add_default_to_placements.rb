class AddDefaultToPlacements < ActiveRecord::Migration[5.2]
  def change
    change_column :placements, :status, :integer, default: 0
  end
end
