class Product < ApplicationRecord
  belongs_to :user
  # A product can be supplied by multiple different vendors
  # has_many :product_vendors, dependent: :destroy
  # has_many :vendors, through: :product_vendors

  # accepts_nested_attributes_for :product_vendors, allow_destroy: true, reject_if: :all_blank

  has_many :order_items, dependent: :restrict_with_error
  has_many :orders, through: :order_items

  validates :name, presence: true
  validates :sku, presence: true, uniqueness: { scope: :user_id }

  has_many :stocks, dependent: :destroy

  def total_quantity
    stocks.sum(:quantity)
  end

  # FIFO Deduction (Oldest stock sold first)  
  def fulfill_order(order_item, quantity_ordered)
    remaining_to_deduct = quantity_ordered
    available_batches = stocks.where("quantity > 0").order(created_at: :asc)

    available_batches.each do |batch|
      break if remaining_to_deduct <= 0

      # Figure out how many we are taking from THIS specific batch
      quantity_taken_from_batch = [batch.quantity, remaining_to_deduct].min

      # 1. LOG IT IN THE DATABASE (The Ledger)
      OrderItemAllocation.create!(
        order_item: order_item,
        stock: batch,
        quantity: quantity_taken_from_batch,
        cost_price: batch.cost_price # We lock in the cost price historically!
      )

      # 2. DO THE MATH
      batch.update!(quantity: batch.quantity - quantity_taken_from_batch)
      remaining_to_deduct -= quantity_taken_from_batch
    end

    if remaining_to_deduct > 0
      raise "Not enough stock across all vendors to fulfill this order!"
    end
  end

  # Handle Order Cancellations (Restocking)
  def restock(quantity_returned)
    # Adds cancelled items back to your most recently updated batch
    latest_batch = stocks.order(updated_at: :desc).first
    
    if latest_batch
      latest_batch.update!(quantity: latest_batch.quantity + quantity_returned)
    else
      # If no batches exist at all, create a generic return batch
      stocks.create!(quantity: quantity_returned, location: "Returns", vendor_id: nil)
    end
  end

end
