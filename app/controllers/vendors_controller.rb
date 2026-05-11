class VendorsController < ApplicationController
  load_and_authorize_resource

  before_action :set_vendor, only: %i[ show edit update destroy ]

  def index
    base_query = current_user.company.vendors.order(created_at: :desc)

    if params[:query].present?
      search_term = "%#{params[:query].downcase.strip}%"
      @vendors_query = base_query.where(
        "LOWER(name) LIKE :q OR LOWER(email) LIKE :q", 
        q: search_term
      )
    else
      @vendors_query = base_query
    end

    @pagy, @vendors = pagy(@vendors_query)
  end

  def show
  end

  def new
    @vendor = current_user.company.vendors.build
  end

  def edit
  end

  def create
    @vendor = current_user.company.vendors.build(vendor_params)

    @vendor.user = current_user

    if @vendor.save
      redirect_to vendor_url(@vendor), notice: "Vendor was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def update
    if @vendor.update(vendor_params)
      redirect_to vendor_url(@vendor), notice: "Vendor was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end
  
  def destroy
    if @vendor.destroy
      redirect_to vendors_url, notice: "Vendor was successfully deleted."
    else
      # Now Rails will tell you EXACTLY what is blocking the deletion
      redirect_to vendors_url, alert: "Could not delete: #{@vendor.errors.full_messages.to_sentence}"
    end
  end

  private

  def set_vendor
    @vendor = current_user.company.vendors.find(params[:id])
  end

  def vendor_params
    params.require(:vendor).permit(:name, :email, :phone)
  end
end
