class Product < ApplicationRecord
  belongs_to :user
  # A product can be supplied by multiple different vendors
  # has_many :product_vendors, dependent: :destroy
  # has_many :vendors, through: :product_vendors

  # accepts_nested_attributes_for :product_vendors, allow_destroy: true, reject_if: :all_blank

  has_many :order_items, dependent: :restrict_with_error
  has_many :orders, through: :order_items

  validates :name, presence: true
  validates :sku, presence: true, uniqueness: { scope: :company_id }
  validates :min_stock_value, presence: true, numericality: { greater_than_or_equal_to: 0 }

  has_many :stocks, dependent: :destroy

  def total_quantity
    stocks.sum(:quantity)
  end

  def fulfill_order(order_item, quantity_ordered)
    remaining_to_deduct = quantity_ordered
    available_batches = stocks.where("quantity > 0").order(created_at: :asc)

    available_batches.each do |batch|
      break if remaining_to_deduct <= 0

      quantity_taken_from_batch = [batch.quantity, remaining_to_deduct].min

      OrderItemAllocation.create!(
        order_item: order_item,
        stock: batch,
        quantity: quantity_taken_from_batch,
        cost_price: batch.cost_price 
      )

      batch.update!(quantity: batch.quantity - quantity_taken_from_batch)
      remaining_to_deduct -= quantity_taken_from_batch
    end

    if remaining_to_deduct > 0
      raise "Not enough stock across all vendors to fulfill this order!"
    end
  end

  def restock(quantity_returned)
    latest_batch = stocks.order(updated_at: :desc).first
    
    if latest_batch
      latest_batch.update!(quantity: latest_batch.quantity + quantity_returned)
    else
      stocks.create!(quantity: quantity_returned, location: "Returns", vendor_id: nil)
    end
  end

end
