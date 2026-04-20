class ConvertProductVendorsToManyToMany < ActiveRecord::Migration[7.1]
  def up
    # 1. Create the join table
    create_table :product_vendors do |t|
      t.references :product, null: false, foreign_key: true
      t.references :vendor, null: false, foreign_key: true
      t.timestamps
    end

    # 2. Safely port your existing data! 
    # This SQL command finds every product that currently has a vendor, 
    # and creates a new link in the join table automatically.
    execute <<-SQL
      INSERT INTO product_vendors (product_id, vendor_id, created_at, updated_at)
      SELECT id, vendor_id, NOW(), NOW()
      FROM products
      WHERE vendor_id IS NOT NULL;
    SQL

    # 3. Now that the data is safe, remove the old hardcoded column
    remove_reference :products, :vendor, foreign_key: true
  end

  def down
    add_reference :products, :vendor, foreign_key: true
    drop_table :product_vendors
  end
end