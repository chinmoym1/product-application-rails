class DropProductVendorsTable < ActiveRecord::Migration[7.1]
  def change
    drop_table :product_vendors, if_exists: true
  end
end
