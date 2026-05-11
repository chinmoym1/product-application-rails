class StocksController < ApplicationController
  load_and_authorize_resource

  before_action :authenticate_user!
  before_action :set_stock, only: %i[ show edit update destroy ]
  before_action :set_dependencies, only: %i[ new edit create update ]

  def index
    base_query = current_user.company.stocks.includes(:product, :vendor).references(:product, :vendor).order(updated_at: :desc)

    if params[:query].present?
      search_term = "%#{params[:query].downcase.strip}%"
      
      @stocks_query = base_query.where(
        "LOWER(products.name) LIKE :q OR LOWER(vendors.name) LIKE :q OR LOWER(products.sku) LIKE :q", 
        q: search_term
      )
    else
      @stocks_query = base_query
    end

    @pagy, @stocks = pagy(@stocks_query)
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
    
    @stock = current_user.company.stocks.build(stock_params)
    
    @stock.product = @product
    # @stock.user = current_user

    if @stock.save
      return_path = session.delete(:stock_return_to) || @stock.product
      redirect_to return_path, notice: "Stock was successfully added."
    else
      set_dependencies 
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

  def set_dependencies
    @vendors = current_user.company.vendors.order(:name)
    @products = current_user.company.products.order(:name)
  end

  def stock_params
    params.require(:stock).permit(:quantity, :location, :vendor_id, :cost_price)
  end
end
