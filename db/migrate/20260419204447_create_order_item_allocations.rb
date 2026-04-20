class CreateOrderItemAllocations < ActiveRecord::Migration[7.1]
  def change
    create_table :order_item_allocations do |t|
      t.references :order_item, null: false, foreign_key: true
      t.references :stock, null: false, foreign_key: true
      t.integer :quantity
      t.decimal :cost_price

      t.timestamps
    end
  end
end
