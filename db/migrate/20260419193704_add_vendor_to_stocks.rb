class AddVendorToStocks < ActiveRecord::Migration[7.1]
  def change
    add_reference :stocks, :vendor, null: true, foreign_key: true
  end
end
