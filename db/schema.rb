# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# This file is the source Rails uses to define your schema when running `bin/rails
# db:schema:load`. When creating a new database, `bin/rails db:schema:load` tends to
# be faster and is potentially less error prone than running all of your
# migrations from scratch. Old migrations may fail to apply correctly if those
# migrations use external dependencies or application code.
#
# It's strongly recommended that you check this file into your version control system.

ActiveRecord::Schema[7.1].define(version: 2026_04_30_063803) do
  # These are extensions that must be enabled in order to support this database
  enable_extension "plpgsql"

  create_table "companies", force: :cascade do |t|
    t.string "name"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
  end

  create_table "customers", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_customers_on_company_id"
    t.index ["email", "company_id"], name: "index_customers_on_email_and_company_id", unique: true
    t.index ["user_id"], name: "index_customers_on_user_id"
  end

  create_table "order_item_allocations", force: :cascade do |t|
    t.bigint "order_item_id", null: false
    t.bigint "stock_id", null: false
    t.integer "quantity"
    t.decimal "cost_price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_item_id"], name: "index_order_item_allocations_on_order_item_id"
    t.index ["stock_id"], name: "index_order_item_allocations_on_stock_id"
  end

  create_table "order_items", force: :cascade do |t|
    t.bigint "order_id", null: false
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.decimal "price_at_purchase"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["order_id"], name: "index_order_items_on_order_id"
    t.index ["product_id"], name: "index_order_items_on_product_id"
  end

  create_table "orders", force: :cascade do |t|
    t.bigint "customer_id", null: false
    t.string "status"
    t.decimal "total_amount"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_orders_on_company_id"
    t.index ["customer_id"], name: "index_orders_on_customer_id"
    t.index ["user_id"], name: "index_orders_on_user_id"
  end

  create_table "permissions", force: :cascade do |t|
    t.bigint "role_id", null: false
    t.string "action"
    t.string "subject_class"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.index ["role_id"], name: "index_permissions_on_role_id"
  end

  create_table "products", force: :cascade do |t|
    t.string "name"
    t.string "sku"
    t.text "description"
    t.decimal "price"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.integer "min_stock_value", default: 10, null: false
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_products_on_company_id"
    t.index ["sku", "company_id"], name: "index_products_on_sku_and_company_id", unique: true
    t.index ["user_id"], name: "index_products_on_user_id"
  end

  create_table "roles", force: :cascade do |t|
    t.string "name"
    t.text "description"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_roles_on_company_id"
  end

  create_table "stocks", force: :cascade do |t|
    t.bigint "product_id", null: false
    t.integer "quantity"
    t.string "location", default: "Main Warehouse"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "vendor_id"
    t.decimal "cost_price"
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_stocks_on_company_id"
    t.index ["product_id"], name: "index_stocks_on_product_id"
    t.index ["vendor_id"], name: "index_stocks_on_vendor_id"
  end

  create_table "users", force: :cascade do |t|
    t.string "email", default: "", null: false
    t.string "encrypted_password", default: "", null: false
    t.string "reset_password_token"
    t.datetime "reset_password_sent_at"
    t.datetime "remember_created_at"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "role_id", null: false
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_users_on_company_id"
    t.index ["email"], name: "index_users_on_email", unique: true
    t.index ["reset_password_token"], name: "index_users_on_reset_password_token", unique: true
    t.index ["role_id"], name: "index_users_on_role_id"
  end

  create_table "vendors", force: :cascade do |t|
    t.string "name"
    t.string "email"
    t.string "phone"
    t.datetime "created_at", null: false
    t.datetime "updated_at", null: false
    t.bigint "user_id"
    t.bigint "company_id", null: false
    t.index ["company_id"], name: "index_vendors_on_company_id"
    t.index ["phone", "company_id"], name: "index_vendors_on_phone_and_company_id", unique: true
    t.index ["user_id"], name: "index_vendors_on_user_id"
  end

  add_foreign_key "customers", "companies"
  add_foreign_key "customers", "users"
  add_foreign_key "order_item_allocations", "order_items"
  add_foreign_key "order_item_allocations", "stocks"
  add_foreign_key "order_items", "orders"
  add_foreign_key "order_items", "products"
  add_foreign_key "orders", "companies"
  add_foreign_key "orders", "customers"
  add_foreign_key "orders", "users"
  add_foreign_key "permissions", "roles"
  add_foreign_key "products", "companies"
  add_foreign_key "products", "users"
  add_foreign_key "roles", "companies"
  add_foreign_key "stocks", "companies"
  add_foreign_key "stocks", "products"
  add_foreign_key "stocks", "vendors"
  add_foreign_key "users", "companies"
  add_foreign_key "users", "roles"
  add_foreign_key "vendors", "companies"
  add_foreign_key "vendors", "users"
end
