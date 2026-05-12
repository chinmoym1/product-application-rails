class RolesController < ApplicationController
  before_action :authenticate_user!
  
  load_and_authorize_resource prepend: true

  def index
    @roles = current_user.company.roles
  end

  def new
    @role.company = current_user.company
  end

  def create
    @role.company = current_user.company
    
    build_dynamic_permissions

    if @role.save
      redirect_to roles_path, notice: "Role was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    @role.assign_attributes(role_params)
    
    build_dynamic_permissions

    if @role.save
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

  def build_dynamic_permissions
    @role.permissions.destroy_all if @role.persisted?
    @role.permissions.clear 

    if params[:permissions].present?
      params[:permissions].each do |subject_class, actions|
        actions.each do |action|
          next if action == "none"
          @role.permissions.build(action: action, subject_class: subject_class)
        end
      end
    end
  end

  def role_params
    params.require(:role).permit(:name, :description)
  end
end