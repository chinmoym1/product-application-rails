class CompaniesController < ApplicationController
  before_action :authenticate_user!
  
  def edit
    @company = current_user.company
    authorize! :update, @company
  end

  def update
    @company = current_user.company
    authorize! :update, @company

    if @company.update(company_params)
      redirect_to edit_company_path, notice: "Company settings updated successfully."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

  def company_params
    params.require(:company).permit(:name)
  end
end