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
    redirect_back fallback_location: root_path, alert: "You have no rights for this operation" unless current_user && current_user.admin?
  end

# Confirms staff user  
  def staff_user
     redirect_back fallback_location: root_path, alert: "You have no rights for this operation" unless current_user && current_user.staff?
  end

# Confirms admin or staff user  
  def admin_or_staff_user
    redirect_back fallback_location: root_path, alert: "This operation is reserved to staff and admins only" unless current_user && (current_user.admin? || current_user.staff?)
  end

  def client_user
     redirect_back fallback_location: root_path, alert: "This operation is reserved to clients" unless current_user && current_user.client?
  end

  def current_client
    Client.find(current_user.client_id) rescue nil
  end

protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :password, :client_id)}
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :role, :password, :current_password, :active, :client_id)}
  end

end
