class CreatePpos < ActiveRecord::Migration[5.2]
  def change
    create_table :ppos do |t|
      t.string :name
      t.date :date
      t.integer :status

      t.belongs_to :product, index: { unique: true }, foreign_key: true
      t.timestamps
    end
  end
end
