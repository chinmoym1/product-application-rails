class AddUserToCoreModels < ActiveRecord::Migration[7.1]
  def change
    add_reference :vendors, :user, foreign_key: true
    add_reference :products, :user, foreign_key: true
    add_reference :customers, :user, foreign_key: true
    add_reference :orders, :user, foreign_key: true
  end
end
