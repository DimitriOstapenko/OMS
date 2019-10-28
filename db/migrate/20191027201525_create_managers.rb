class CreateManagers < ActiveRecord::Migration[5.2]
  def change
    create_table :managers do |t|
      t.string :lname
      t.string :fname
      t.string :phone
      t.string :email

      t.timestamps
    end
  end
end
