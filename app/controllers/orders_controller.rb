class OrdersController < ApplicationController

  load_and_authorize_resource

  before_action :set_order, only: %i[ show edit update destroy ]
  before_action :set_dependencies, only: %i[ new edit create update ]

  def index
    # @orders = current_user.company.orders.includes(:customer).order(created_at: :desc)
    base_query = current_user.company.orders.includes(:customer).references(:customer).order(created_at: :desc)

    if params[:query].present?
      raw_query = params[:query].downcase.strip
      
      id_term = raw_query.gsub(/[^0-9]/, '')
      id_term = id_term.to_i.to_s if id_term.present?

      @orders_query = base_query.where(
        "orders.id::text LIKE :id_query OR LOWER(customers.email) LIKE :email_query", 
        id_query: "%#{id_term}%",
        email_query: "%#{raw_query}%"
      )
    else
      @orders_query = base_query
    end

    @pagy, @orders = pagy(@orders_query)
  end

  def show
    @order = current_user.company.orders.includes(
      order_items: { 
        product: [], 
        order_item_allocations: { stock: :vendor } 
      }
    ).find(params[:id])
  end

  def new
    @order = current_user.company.orders.build
    @order.order_items.build 
  end

  def edit
  end

  def create
    @order = current_user.company.orders.build(order_params)

    @order.user = current_user

    if params[:order][:customer_email].present?
      clean_email = params[:order][:customer_email].strip.downcase
      
      @order.customer = current_user.company.customers.find_or_create_by!(email: clean_email) do |new_customer|
        raw_name = clean_email.split('@').first
        new_customer.name = raw_name.tr('._-', ' ').titleize

        new_customer.user = current_user
      end
    end

    calculate_total_amount

    if @order.save
      OrderMailer.order_details(@order).deliver_later
      redirect_to order_url(@order), notice: "Order was successfully created."
    else
      @customers = current_user.company.customers 
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
    @order = current_user.company.orders.find(params[:id])
  end

  def set_dependencies
    @customers = current_user.company.customers
    @products = current_user.company.products
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