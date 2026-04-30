class UpdateCoreUniquenessIndexes < ActiveRecord::Migration[7.1]
  def change
    remove_index :products, :sku if index_exists?(:products, :sku)
    remove_index :products, [:sku, :user_id] if index_exists?(:products, [:sku, :user_id])
    add_index :products, [:sku, :company_id], unique: true

    remove_index :vendors, :phone if index_exists?(:vendors, :phone)
    remove_index :vendors, [:phone, :user_id] if index_exists?(:vendors, [:phone, :user_id])
    add_index :vendors, [:phone, :company_id], unique: true

    remove_index :customers, :email if index_exists?(:customers, :email)
    remove_index :customers, [:email, :user_id] if index_exists?(:customers, [:email, :user_id])
    add_index :customers, [:email, :company_id], unique: true
  end
end
