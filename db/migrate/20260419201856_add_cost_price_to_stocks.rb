class AddCostPriceToStocks < ActiveRecord::Migration[7.1]
  def change
    add_column :stocks, :cost_price, :decimal
  end
end
