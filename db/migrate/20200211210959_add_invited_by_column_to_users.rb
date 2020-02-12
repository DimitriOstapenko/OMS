class AddInvitedByColumnToUsers < ActiveRecord::Migration[5.2]
  def change
    add_column :users, :invited_by, :string, default: nil
  end
end
