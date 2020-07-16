class AddUserToInventories < ActiveRecord::Migration[5.2]
  def change
    add_reference :inventories, :user, foreign_key: true
    remove_column :inventories, :uploaded_by, :integer
  end
end
