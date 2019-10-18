class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :name
      t.integer :type
      t.string :code
      t.string :description
      t.string :country
      t.string :state_prov
      t.string :address
      t.string :zip
      t.string :email
      t.string :phone

      t.timestamps
    end
  end
end
