class DashboardController < ApplicationController
  before_action :authenticate_user!

  def index
    if can?(:manage, Product) || can?(:read, Product)
      redirect_to products_path
    elsif can?(:manage, Order)
      redirect_to orders_path
    else
      render plain: "Welcome! Please wait for an admin to assign your permissions."
    end
  end
end

