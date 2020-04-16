class MyRegistrationsController < Devise::RegistrationsController

# Log in user after registration
  def after_confirmation_path_for(resource_name, resource)    
    sign_in(resource)
    redirect_to products_path
  end

end
