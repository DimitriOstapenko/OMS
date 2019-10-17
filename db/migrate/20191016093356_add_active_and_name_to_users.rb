class AddActiveAndNameToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :name, :string
    add_column :users, :active, :boolean, default: true
  end
end
