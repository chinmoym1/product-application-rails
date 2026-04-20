class ProductVendorsController < ApplicationController
  def create
    @product = current_user.products.find(params[:product_id])
    @product_vendor = @product.product_vendors.build(product_vendor_params)

    if @product_vendor.save
      redirect_to @product, notice: "Vendor pricing added successfully!"
    else
      redirect_to @product, alert: "Could not add vendor. Please ensure a price is entered."
    end
  end

  def destroy
    @product = current_user.products.find(params[:product_id])
    @product_vendor = @product.product_vendors.find(params[:id])
    
    @product_vendor.destroy
    redirect_to @product, notice: "Vendor removed from this product."
  end

  private

  def product_vendor_params
    params.require(:product_vendor).permit(:vendor_id, :cost_price)
  end
end