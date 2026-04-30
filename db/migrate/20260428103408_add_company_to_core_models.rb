class AddCompanyToCoreModels < ActiveRecord::Migration[7.1]
  def up
    add_reference :products, :company, null: true, foreign_key: true
    add_reference :vendors, :company, null: true, foreign_key: true
    add_reference :customers, :company, null: true, foreign_key: true
    add_reference :orders, :company, null: true, foreign_key: true

    default_company = Company.first || Company.create!(name: 'Product Info')

    Product.update_all(company_id: default_company.id)
    Vendor.update_all(company_id: default_company.id)
    Customer.update_all(company_id: default_company.id)
    Order.update_all(company_id: default_company.id)

    change_column_null :products, :company_id, false
    change_column_null :vendors, :company_id, false
    change_column_null :customers, :company_id, false
    change_column_null :orders, :company_id, false
  end

  def down
    remove_reference :orders, :company
    remove_reference :customers, :company
    remove_reference :vendors, :company
    remove_reference :products, :company
  end
end