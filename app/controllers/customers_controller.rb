class CustomersController < ApplicationController
  before_action :set_customer, only: %i[ show edit update destroy ]

  def index
    @customers = current_user.customers.order(created_at: :desc)
  end

  def show
    # Fetch all orders
    @orders = @customer.orders.order(created_at: :desc)
  end

  def new
    @customer = current_user.customers.build
  end

  def edit
  end

  def create
    @customer = current_user.customers.build(customer_params)

    if @customer.save
      redirect_to customer_url(@customer), notice: "Customer was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @customer.update(customer_params)
      redirect_to customer_url(@customer), notice: "Customer was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @customer.destroy
      redirect_to customers_url, notice: "Customer was successfully deleted."
    else
      redirect_to customers_url, alert: "Could not delete: #{@customer.errors.full_messages.to_sentence}"
    end
  end

  private

  def set_customer
    @customer = current_user.customers.find(params[:id])
  end

  def customer_params
    params.require(:customer).permit(:name, :email)
  end
end