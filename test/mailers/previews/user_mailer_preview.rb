# Preview all emails at http://localhost:3000/rails/mailers/user_mailer
class UserMailerPreview < ActionMailer::Preview

# Notify staff about new user registration
  def new_registration
    user = User.first
    UserMailer.new_registration(user)
  end  

  def new_product
    @product = Product.first 
    UserMailer.new_product(@product)
  end

end
