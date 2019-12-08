class AddTargetToClientMails < ActiveRecord::Migration[5.2]
  def change
    add_column :client_mails, :target_emails, :text
  end
end
