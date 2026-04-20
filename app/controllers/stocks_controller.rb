class StocksController < ApplicationController
  before_action :authenticate_user!
  before_action :set_stock, only: %i[ show edit update ]

  def index
    @stocks = current_user.stocks.includes(:product, :vendor).order(updated_at: :desc)
  end

  def show
  end

  def edit
    session[:stock_return_to] = request.referer
  end

  def new
    session[:stock_return_to] = request.referer

    @product = current_user.products.find(params[:product_id])
    @stock = @product.stocks.build
  end

  def create
    @product = current_user.products.find(params[:product_id])
    @stock = @product.stocks.build(stock_params)

    # By default, a new shipment is handled by the current user's warehouse
    @stock.user_id = current_user.id if @stock.respond_to?(:user_id=)

    if @stock.save
      return_path = session.delete(:stock_return_to) || @stock.product
      redirect_to return_path, notice: "Stock was successfully added."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @stock.update(stock_params)
      return_path = session.delete(:stock_return_to) || @stock.product
      redirect_to return_path, notice: "Stock was successfully updated."
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
