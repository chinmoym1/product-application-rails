class AddCompanyToRoles < ActiveRecord::Migration[7.1]
  def up
    add_reference :roles, :company, null: true, foreign_key: true

    default_company = Company.find_or_create_by!(name: 'Product Info')

    Role.update_all(company_id: default_company.id)

    change_column_null :roles, :company_id, false
  end

  def down
    remove_reference :roles, :company
  end
end