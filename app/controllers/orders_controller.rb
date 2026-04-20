class OrdersController < ApplicationController
  before_action :set_order, only: %i[ show edit update destroy ]
  before_action :set_dependencies, only: %i[ new edit create update ]

  def index
    @orders = current_user.orders.includes(:customer).order(created_at: :desc)
  end

  def show
    @order = current_user.orders.includes(
      order_items: { 
        product: [], 
        order_item_allocations: { stock: :vendor } 
      }
    ).find(params[:id])
  end

  def new
    @order = current_user.orders.build
    @order.order_items.build # Starts the form with one empty product row
  end

  def edit
  end

  def create
    @order = current_user.orders.build(order_params)

    if params[:order][:customer_email].present?
      clean_email = params[:order][:customer_email].strip.downcase
      
      @order.customer = current_user.customers.find_or_create_by!(email: clean_email) do |new_customer|
        # Auto-generates a clean name like "John Doe" from "john.doe@gmail.com"
        raw_name = clean_email.split('@').first
        new_customer.name = raw_name.tr('._-', ' ').titleize
      end
    end

    calculate_total_amount

    if @order.save
      redirect_to order_url(@order), notice: "Order was successfully created."
    else
      # We must reload the customers list so the dropdown doesn't break if an error happens!
      @customers = current_user.customers 
      render :new, status: :unprocessable_entity
    end
  end

  def update
    @order.assign_attributes(order_params)
    calculate_total_amount

    if @order.save
      redirect_to order_url(@order), notice: "Order was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @order.destroy
      redirect_to orders_url, notice: "Order was successfully deleted."
    else
      redirect_to orders_url, alert: "Could not delete: #{@order.errors.full_messages.to_sentence}"
    end
  end

  private

  def set_order
    @order = current_user.orders.find(params[:id])
  end

  def set_dependencies
    @customers = current_user.customers
    @products = current_user.products
  end

  def calculate_total_amount
    # Maps and calculates the total before saving
    @order.total_amount = @order.order_items.reject(&:marked_for_destruction?).sum do |item|
      item.quantity.to_i * item.price_at_purchase.to_f
    end
  end

  def order_params
    params.require(:order).permit(
      :customer_email, :status, 
      order_items_attributes: [:id, :product_id, :quantity, :price_at_purchase, :_destroy]
    )
  end
end