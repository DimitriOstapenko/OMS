class CreateClientMails < ActiveRecord::Migration[5.2]
  def change
    create_table :client_mails do |t|
      t.datetime :ts_sent
      t.integer :client_type
      t.integer :category
      t.text :body

      t.timestamps
    end
  end
end
