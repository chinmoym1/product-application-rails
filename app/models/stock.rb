class Stock < ApplicationRecord
  attribute :location, :string, default: "Main Warehouse"
  
  belongs_to :product
  belongs_to :vendor, optional: true

  has_many :order_item_allocations, dependent: :restrict_with_error

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }
end
