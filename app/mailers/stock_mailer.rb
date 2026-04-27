class StockMailer < ApplicationMailer
  default from: 'notifications@productinfo.Pvt.Ltd'

  def stock_alert(stock)
    @stock = stock
    @product = stock.product
    @vendor = stock.vendor
    mail(to: @vendor.user.email, subject: "Low Stock Alert - #{@product.name}")
  end
end
