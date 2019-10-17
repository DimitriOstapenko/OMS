class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
  include UsersHelper

  before_action :configure_permitted_parameters, if: :devise_controller?

# Confirms a logged-in user.
  def logged_in_user
    unless current_user
      store_location
      redirect_to user_session_path, flash: {warning: "Please log in."} 
    end
  end

# Confirms an admin user.
  def admin_user
    redirect_to(root_url) unless current_user && current_user.admin?
  end

protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :password)}
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :role, :password, :current_password)}
  end
end
