class CreateTableNotes < ActiveRecord::Migration[5.2]
  def change
    create_table :table_notes do |t|
      t.string :table_name
      t.text :notes

      t.timestamps
    end
  end
end
