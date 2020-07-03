class AddPlistToPlacements < ActiveRecord::Migration[5.2]
  def change
    add_reference :placements, :packing_list, foreign_key: true
  end
end
