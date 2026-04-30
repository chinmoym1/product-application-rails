class AddRoleToUsers < ActiveRecord::Migration[7.1]
  def up
    add_reference :users, :role, null: true, foreign_key: true

    default_role = Role.find_or_create_by!(name: 'Cashier', description: 'For order management')
    User.update_all(role_id: default_role.id)
    change_column_null :users, :role_id, false
  end

  def down
    remove_reference :users, :role
  end
end
