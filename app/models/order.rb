class Order < ApplicationRecord  
  belongs_to :user
  belongs_to :customer
  has_many :order_items, dependent: :destroy
  accepts_nested_attributes_for :order_items, allow_destroy: true

  attr_accessor :customer_email

  validate :check_inventory_levels
  validate :order_is_locked_after_completion, on: :update
  validate :must_have_at_least_one_item

  before_save :calculate_inventory_adjustments
  after_save :execute_inventory_adjustments

  private

  # Helper Methods
  def holds_inventory?
    ["Pending", "Processing", "Completed"].include?(status)
  end

  def returns_inventory?
    ["Cancelled", "Returned"].include?(status)
  end

  # Validations
  def check_inventory_levels
    return unless holds_inventory?

    order_items.each do |item|
      next if item.marked_for_destruction?

      additional_needed = calculate_delta(item)

      if additional_needed > 0
        stock_available = item.product.total_quantity

        if stock_available < additional_needed
          errors.add(:base, "Not enough stock for #{item.product.name}. You need #{additional_needed} more, but only #{stock_available} are available.")
        end
      end
    end
  end

  def order_is_locked_after_completion
    if status_was == "Completed"
      tampered_attributes = changed - ["status", "updated_at"]
      items_tampered = order_items.any? { |item| item.changed? || item.marked_for_destruction? || item.new_record? }

      if tampered_attributes.any? || items_tampered
        errors.add(:base, "Completed orders are permanently locked for accounting purposes. You may only update the order Status.")
      end
    end
  end

  def must_have_at_least_one_item
    if order_items.reject(&:marked_for_destruction?).empty?
      errors.add(:base, "An order must contain at least one product.")
    end
  end

  # --- Inventory Math ---

  def calculate_inventory_adjustments
    @product_adjustments ||= [] 

    # Scenario A: Order just placed, OR changed from Cancelled back to Active
    if holds_inventory? && (new_record? || ["Cancelled", "Returned"].include?(status_was))
      order_items.reject(&:marked_for_destruction?).each do |item|
        @product_adjustments << { item: item, product: item.product, change: -item.quantity.to_i }
      end

    # Scenario B: Order was Active, but is now Cancelled/Returned
    elsif returns_inventory? && ["Pending", "Processing", "Completed"].include?(status_was)
      order_items.each do |item|
        item.order_item_allocations.each do |alloc|
          alloc.stock.update_columns(quantity: alloc.stock.quantity + alloc.quantity)
        end
        item.order_item_allocations.destroy_all
      end

    # Scenario C: Order remains Active, but the user edited items
    elsif holds_inventory? && !new_record? && ["Pending", "Processing", "Completed"].include?(status_was)
      order_items.each do |item|

        if item.marked_for_destruction?
          # 1. Item was deleted from the order: Refund exact allocations
          item.order_item_allocations.each do |alloc|
            alloc.stock.update_columns(quantity: alloc.stock.quantity + alloc.quantity)
          end
          item.order_item_allocations.destroy_all

        elsif item.new_record?
          # 2. Brand new item was added to the order: Deduct fresh stock
          @product_adjustments << { item: item, product: item.product, change: -item.quantity.to_i }

        elsif item.quantity_changed? || item.product_id_changed?
          # 3. Item was edited (qty changed or product swapped): Wipe & Re-allocate
          # First, refund all existing allocations back to their exact vendor batches
          item.order_item_allocations.each do |alloc|
            alloc.stock.update_columns(quantity: alloc.stock.quantity + alloc.quantity)
          end
          item.order_item_allocations.destroy_all

          # Second, queue up a fresh allocation request for the new product/quantity
          @product_adjustments << { item: item, product: item.product, change: -item.quantity.to_i }
        end
        
      end
    end
  end

  def execute_inventory_adjustments
    return if @product_adjustments.blank?

    @product_adjustments.each do |adj|
      if adj[:change] < 0
        # If change is negative, it's a sale. Trigger the FIFO deduction!
        adj[:product].fulfill_order(adj[:item], adj[:change].abs)
      elsif adj[:change] > 0
        # If change is positive, it's a return/cancellation. Add it back!
        adj[:product].restock(adj[:change])
      end
    end

    @product_adjustments = nil
  end

  def calculate_delta(item)
    if new_record? || (holds_inventory? && ["Cancelled", "Returned"].include?(status_was))
      item.quantity.to_i
    elsif item.new_record?
      item.quantity.to_i
    elsif item.product_id_changed?
      item.quantity.to_i
    elsif item.quantity_changed?
      item.quantity.to_i - item.quantity_was.to_i
    else
      0
    end
  end
  
end


