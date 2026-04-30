class AddCompanyToUsers < ActiveRecord::Migration[7.1]
  def up
    add_reference :users, :company, null: true, foreign_key: true

    default_company = Company.find_or_create_by!(name: 'Product Info')

    User.update_all(company_id: default_company.id)

    change_column_null :users, :company_id, false
  end

  def down
    remove_reference :users, :company
  end
end