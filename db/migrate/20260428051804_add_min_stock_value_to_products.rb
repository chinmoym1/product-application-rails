class AddMinStockValueToProducts < ActiveRecord::Migration[7.1]
  def change
    add_column :products, :min_stock_value, :integer, default: 10, null: false
  end
end
