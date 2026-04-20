class ProductVendor < ApplicationRecord
  belongs_to :product
  belongs_to :vendor

  validates :cost_price, presence: true
end