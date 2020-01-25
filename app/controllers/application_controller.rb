class ApplicationController < ActionController::Base

  protect_from_forgery with: :exception
#  protect_from_forgery with: :null_session
#  protect_from_forgery prepend: true, with: :exception

#!!!  
  skip_before_action :verify_authenticity_token 

  include UsersHelper
  helper_method :add_to_cart, :get_cart, :clear_cart, :current_client

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
    redirect_back fallback_location: root_path, alert: "This operation is reserved to admin users only" unless current_user && current_user.admin?
  end

# Confirms staff user  
  def staff_user
     redirect_back fallback_location: root_path, alert: "This operation is reserved for staff users only" unless current_user && current_user.staff?
  end

# Confirms admin or staff user  
  def admin_or_staff_user
    redirect_back fallback_location: root_path, alert: "This operation is reserved to staff and admins only" unless current_user && (current_user.admin? || current_user.staff?)
  end

  def client_user
     redirect_back fallback_location: root_path, alert: "This operation is reserved to client users only" unless current_user && current_user.client?
  end

  def no_user_user
     redirect_back fallback_location: root_path, alert: "You have no rights for this operation" if current_user && current_user.user?
  end

  def current_client
    Client.find(current_user.client_id) rescue nil
  end

  def add_to_cart?(product_id,qty)
    qty = qty.to_i rescue nil
    return unless product_id && qty
    return unless qty > 0 
    temp = session[:cart] || []
    temp.push([product_id, qty])

#   clean up possible duplicates: join keys, add values (qty)
    session[:cart] = temp.group_by(&:first).map { |k, v| [ k, v.sum{|e| e[1].to_i} ] }
  end

  def get_cart
    session[:cart] ||= []
    return session[:cart] 
  end
  
  def clear_cart
    session[:cart] = []
  end
  
protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up) { |u| u.permit(:name, :email, :password, :client_id)}
    devise_parameter_sanitizer.permit(:account_update) { |u| u.permit(:name, :email, :role, :password, :current_password, :active, :client_id)}
  end

end
