class StocksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stock, only: %i[ show edit update ]

  def index
    @stocks = current_user.stocks.includes(product: :vendors).order(updated_at: :desc)
  end

  def show
  end

  def edit
  end

  def new
    @product = current_user.products.find(params[:product_id])
    @stock = @product.stocks.build
  end

  def create
    @product = current_user.products.find(params[:product_id])
    @stock = @product.stocks.build(stock_params)

    # By default, a new shipment is handled by the current user's warehouse
    @stock.user_id = current_user.id if @stock.respond_to?(:user_id=)

    if @stock.save
      redirect_to @product, notice: "Shipment received successfully!"
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @stock.update(stock_params)
      redirect_to product_path(@stock.product), notice: "Stock batch was successfully updated."   
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def set_stock
    @stock = current_user.stocks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to stocks_path, alert: "Stock record not found."
  end

  def stock_params
    params.require(:stock).permit(:quantity, :location, :vendor_id, :cost_price)
  end
end
