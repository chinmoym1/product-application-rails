class AddCostPriceToProductVendors < ActiveRecord::Migration[7.1]
  def change
    add_column :product_vendors, :cost_price, :decimal
  end
end
