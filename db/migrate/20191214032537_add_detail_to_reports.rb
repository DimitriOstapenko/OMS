class AddDetailToReports < ActiveRecord::Migration[5.2]
  def change
    add_column :reports, :detail, :integer
  end
end
