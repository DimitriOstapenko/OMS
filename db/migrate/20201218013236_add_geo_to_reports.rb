class AddGeoToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :geo, :integer, default: 0
  end
end
