class MyRegistrationsController < Devise::RegistrationsController

#  def build_resource(*args)
#    super
#    if session[:no_confirm]
#       @user.mark_as_confirmed
#    end
#  end
  
# Log in user after registration
  def after_confirmation_path_for(resource_name, resource)    
    sign_in(resource)
    redirect_to products_path
  end

#  def create
#    super
#    if @user.persisted?
#      UserMailer.new_registration(@user).deliver
#    end
#  end

end
