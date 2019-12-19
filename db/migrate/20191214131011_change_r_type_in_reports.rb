class ChangeRTypeInReports < ActiveRecord::Migration[5.2]
  def change
    change_column :reports, :rtype, :string
  end
end
