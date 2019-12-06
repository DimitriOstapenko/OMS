class CreateReports < ActiveRecord::Migration[5.2]
  def change
    create_table :reports do |t|
      t.string :name
      t.integer :client_id
      t.integer :rtype
      t.integer :timeframe
      t.date :sdate
      t.date :edate
      t.string :filename

      t.timestamps
    end
  end
end
