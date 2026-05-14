class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :authenticate_user!
  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from CanCan::AccessDenied do |exception|
    exception.default_message = "You do not have permission to access that page."
    respond_to do |format|
      format.json { head :forbidden }
      format.html { redirect_to root_path, alert: exception.message }
    end
  end

  def after_sign_in_path_for(resource)
      root_path
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:account_update, keys: [:name, :avatar, :remove_avatar])
  end
end
