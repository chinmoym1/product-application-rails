class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    @products_count = Product.accessible_by(current_ability).count if can?(:read, Product)
    @vendors_count = Vendor.accessible_by(current_ability).count if can?(:read, Vendor)
    @stocks_count = Stock.accessible_by(current_ability).count if can?(:read, Stock)
    @orders_count = Order.accessible_by(current_ability).count if can?(:read, Order)
    @customers_count = Customer.accessible_by(current_ability).count if can?(:read, Customer)
    
    if current_user.role&.name == 'Admin'
      @users_count = current_user.company.users.count
    end
  end
end
