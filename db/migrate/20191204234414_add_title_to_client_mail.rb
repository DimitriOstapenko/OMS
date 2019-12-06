class AddTitleToClientMail < ActiveRecord::Migration[5.2]
  def change
    add_column :client_mails, :title, :string
  end
end
