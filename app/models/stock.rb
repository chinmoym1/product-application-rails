class Stock < ApplicationRecord
  attribute :location, :string, default: "Main Warehouse"
  
  belongs_to :product
  belongs_to :vendor, optional: true

  has_many :order_item_allocations, dependent: :restrict_with_error

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  validate :cost_price_check

  after_update :check_stock_count

  private

  def cost_price_check
    return if cost_price.blank? || product.nil? || product.price.blank?

    if cost_price >= product.price
      errors.add(:cost_price, "must be less than the retail price (₹#{product.price}).")
    end
  end

  def check_stock_count
    if saved_change_to_quantity? && quantity < 10 && quantity_before_last_save >= 10
      StockMailer.stock_alert(self).deliver_later
    end
  end

  

end
