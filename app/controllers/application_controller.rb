class ApplicationController < ActionController::Base
  include Pundit::Authorization

  layout :layout_by_resource

  rescue_from Pundit::NotAuthorizedError, with: :user_not_authorized

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: [:role])
  end

  def user_not_authorized
    flash[:alert] = "You're not authorized to do that."
    redirect_to(request.referrer || root_path)
  end

  # Devise pages (sign in, sign up, password reset) use the full-screen
  # auth layout; everything else uses the normal app layout.
  def layout_by_resource
    devise_controller? ? "auth" : "application"
  end
end