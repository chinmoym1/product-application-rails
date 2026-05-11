class ProductsController < ApplicationController
  load_and_authorize_resource
  
  before_action :set_product, only: %i[ show edit update destroy ]
  before_action :set_vendors, only: %i[ new edit create update ]

  def index
    base_query = current_user.company.products.includes(:stocks).order(created_at: :desc)

    if params[:query].present?
      search_term = "%#{params[:query].downcase.strip}%"

      @products_query = base_query.where(
        "LOWER(name) LIKE :q OR LOWER(sku) LIKE :q", 
        q: search_term
      )
    else
      @products_query = base_query
    end

    @pagy, @products = pagy(@products_query)
  end


  def show
  end

  def new
    @product = current_user.company.products.build
  end

  def edit
  end

  def create
    @product = current_user.company.products.build(product_params)

    @product.user = current_user

    if @product.save      
      redirect_to product_url(@product), notice: "Product was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @product.update(product_params)
      redirect_to product_url(@product), notice: "Product was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    if @product.destroy
      redirect_to products_url, notice: "Product was successfully deleted."
    else
      redirect_to products_url, alert: "Could not delete: #{@product.errors.full_messages.to_sentence}"
    end
  end

  private

  def set_product
    @product = current_user.company.products.find(params[:id])
  end

  def set_vendors
    @vendors = current_user.company.vendors
  end

  def product_params
    params.require(:product).permit(:name, :sku, :description, :price, :min_stock_value)
  end
end