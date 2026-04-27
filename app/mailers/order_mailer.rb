class OrderMailer < ApplicationMailer
  default from: "notifications@productinfo.Pvt.Ltd"

  def order_details(order)
    @order = order
    @customer = order.customer
    mail(
      to: @customer.email,
      # cc: @order.user.email,
      subject: "Order Confirmation - Invoice ##{@order.id}"
      )
  end
end
