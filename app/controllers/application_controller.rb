class ApplicationController < ActionController::Base
  include Pagy::Backend
  before_action :authenticate_user!

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
end
