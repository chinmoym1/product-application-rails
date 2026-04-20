class VendorsController < ApplicationController
  before_action :set_vendor, only: %i[ show edit update destroy ]

  def index
    @vendors = current_user.vendors
  end

  def show
  end

  def new
    @vendor = current_user.vendors.build
  end

  def edit
  end

  def create
    @vendor = current_user.vendors.build(vendor_params)

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
    @vendor = current_user.vendors.find(params[:id])
  end

  def vendor_params
    params.require(:vendor).permit(:name, :email, :phone)
  end
end
