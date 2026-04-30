class Stock < ApplicationRecord
  attribute :location, :string, default: "Main Warehouse"
  
  belongs_to :company
  belongs_to :product
  belongs_to :vendor, optional: true

  has_many :order_item_allocations, dependent: :restrict_with_error

  validates :quantity, numericality: { greater_than_or_equal_to: 0 }

  validate :check_cost_price

  after_update :check_stock_count

  private

  def check_cost_price
    return if cost_price.blank? || product.nil? || product.price.blank?

    if cost_price >= product.price
      errors.add(:cost_price, "must be less than the retail price (₹#{product.price}).")
    end 
  end

  def check_stock_count
    minStock = product.min_stock_value

    if saved_change_to_quantity? && quantity < minStock && quantity_before_last_save >= minStock
      StockMailer.stock_alert(self).deliver_later
    end
  end

  

end
