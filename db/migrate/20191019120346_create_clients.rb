class CreateClients < ActiveRecord::Migration[5.2]
  def change
    create_table :clients do |t|
      t.string :name
      t.integer :type, default: 0
      t.string :code
      t.string :country
      t.string :state_prov
      t.string :address
      t.string :zip_postal
      t.string :email
      t.string :phone
      t.string :contact_person
      t.string :web
      t.text :notes

      t.timestamps
    end
  end
end
