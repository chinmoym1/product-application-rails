class RolesController < ApplicationController
  before_action :authenticate_user!
  
  load_and_authorize_resource 

  def index
    @roles = current_user.company.roles
  end

  def new
    @role = current_user.company.roles.build
  end

  def create
    @role = current_user.company.roles.build(role_params)

    if @role.save
      redirect_to roles_path, notice: "Role was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @role.update(role_params)
      redirect_to roles_path, notice: "Role was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    if @role.name == 'Admin'
      redirect_to roles_path, alert: "You cannot delete the core Admin role."
    else
      @role.destroy
      redirect_to roles_path, notice: "Role was successfully deleted."
    end
  end

  private

  def role_params
    params.require(:role).permit(:name, :description, permission_ids: [])
  end
end