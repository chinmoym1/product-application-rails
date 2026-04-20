class OrderItemAllocation < ApplicationRecord
  belongs_to :order_item
  belongs_to :stock
end
