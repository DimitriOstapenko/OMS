class DropColumnFromPlacements < ActiveRecord::Migration[5.2]
  def change
    remove_column :placements, :last_pl_id, :integer
  end
end
