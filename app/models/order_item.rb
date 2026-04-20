class OrderItem < ApplicationRecord
  belongs_to :order
  belongs_to :product

  has_many :order_item_allocations, dependent: :destroy

  validates :quantity, presence: true, numericality: { only_integer: true, greater_than: 0 }
  validates :price_at_purchase, presence: true, numericality: { greater_than_or_equal_to: 0 }

  # A method for total 
  def total_price
    quantity * price_at_purchase
  end
end
