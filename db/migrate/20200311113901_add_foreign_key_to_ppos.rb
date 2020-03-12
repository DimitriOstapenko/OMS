class AddForeignKeyToPpos < ActiveRecord::Migration[5.2]
  def change
    add_reference :placements, :ppo
    add_foreign_key :placements, :ppos
  end
end
