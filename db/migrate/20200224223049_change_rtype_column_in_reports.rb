class ChangeRtypeColumnInReports < ActiveRecord::Migration[5.2]
  def change
    remove_column :reports, :rtype, :string
    add_column :reports, :status, :integer, default: 0
  end
end
