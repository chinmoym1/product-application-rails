class AddDefaultLocationToStocks < ActiveRecord::Migration[7.1]
  def change
    change_column_default :stocks, :location, "Main Warehouse"
  end
end
