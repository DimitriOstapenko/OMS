class CreateSuppliers < ActiveRecord::Migration[5.2]
  def change
    create_table :suppliers do |t|
      t.string :company
      t.string :lname
      t.string :fname
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end
