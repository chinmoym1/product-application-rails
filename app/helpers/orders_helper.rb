module OrdersHelper
  def invoice_number(order)
    year = order.created_at.strftime("%Y")
    number = format("%05d", order.id)
    "INV-#{year}-#{number}"
  end
end
