class AddCompanyToStocks < ActiveRecord::Migration[7.1]
  def up
    add_reference :stocks, :company, null: true, foreign_key: true

    default_company = Company.first

    Stock.update_all(company_id: default_company.id)

    change_column_null :stocks, :company_id, false
  end

  def down
    remove_reference :stocks, :company
  end
end
