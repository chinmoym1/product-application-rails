class StocksController < ApplicationController
  load_and_authorize_resource

  before_action :authenticate_user!
  before_action :set_stock, only: %i[ show edit update destroy ]

  def index
    @stocks = current_user.company.stocks.includes(:product, :vendor).order(updated_at: :desc)
  end

  def show
  end

  def edit
    session[:stock_return_to] = request.referer
  end

  def new
    session[:stock_return_to] = request.referer

    @product = current_user.company.products.find(params[:product_id])
    @stock = @product.stocks.build
  end

  def create
    @product = current_user.company.products.find(params[:product_id])
    @stock = @product.company.stocks.build(stock_params)

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

  def destroy
    if @stock.destroy
      return_path = request.referer || stocks_path
      redirect_to return_path, notice: "Stock record was successfully deleted."
    else
      return_path = request.referer || stocks_path
      redirect_to return_path, alert: "Could not delete: #{@stock.errors.full_messages.to_sentence}"
    end
  end

  private

  def set_stock
    @stock = current_user.company.stocks.find(params[:id])
  rescue ActiveRecord::RecordNotFound
    redirect_to stocks_path, alert: "Stock record not found."
  end

  def stock_params
    params.require(:stock).permit(:quantity, :location, :vendor_id, :cost_price)
  end
end
