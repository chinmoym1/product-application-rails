class Company < ApplicationRecord
  has_many :users
  has_many :roles
  has_many :products
  has_many :vendors
  has_many :customers
  has_many :orders
  has_many :stocks
end
