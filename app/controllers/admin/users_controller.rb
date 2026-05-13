class Admin::UsersController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin!

  def index
    base_query = current_user.company.users.includes(:role).order(created_at: :desc)

    if params[:query].present?
      search_term = "%#{params[:query].downcase.strip}%"

      @users_query = base_query.where(
        "LOWER(email) LIKE :q", 
        q: search_term
      )
    else
      @users_query = base_query
    end

    @pagy, @users = pagy(@users_query)
  end

  def new
    @user = User.new
  end

  def create
    @user = current_user.company.users.build(user_params)
    
    if @user.save
      redirect_to admin_users_path, notice: "User was successfully created directly."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def new_invite
    @user = User.new
  end

  def send_invite
    @user = User.invite!(invite_params, current_user)
    
    if @user.errors.empty?
      redirect_to admin_users_path, notice: "Invitation securely sent to #{@user.email}."
    else
      render :new_invite, status: :unprocessable_entity
    end
  end

  def edit
    @user = current_user.company.users.find(params[:id])
  end

  def update
    @user = current_user.company.users.find(params[:id])

    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end

    if @user.update(user_params)
      redirect_to admin_users_path, notice: "User was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @user = current_user.company.users.find(params[:id])
    @user.destroy
    redirect_to admin_users_path, notice: "User deleted."
  end

  private

  def require_admin!
    unless current_user.role&.name == 'Admin'
      redirect_to root_path, alert: "Access denied. Admins only."
    end
  end

  def user_params
    params.require(:user).permit(:email, :role_id, :password, :password_confirmation)
  end

  def invite_params
    params.require(:user).permit(:email, :role_id).merge(company_id: current_user.company_id)
  end
end