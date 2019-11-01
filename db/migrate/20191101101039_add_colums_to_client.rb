class AddColumsToClient < ActiveRecord::Migration[5.2]
  def change
    remove_column :clients, :contact_person, :string
    remove_column :clients, :phone, :string
    remove_column :clients, :email, :string
    add_column :clients, :contact_fname, :string
    add_column :clients, :contact_lname, :string
    add_column :clients, :vat, :string
    add_column :clients, :contact_phone, :string
    add_column :clients, :contact_email, :string
  end
end
