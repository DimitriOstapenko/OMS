# Send emails to single client
class ClientMailer < ApplicationMailer
  
  def send_invite_to_register(client,user)
    @client = client; @user = user
    @raw, hashed = Devise.token_generator.generate(User, :reset_password_token) 
    @user.reset_password_sent_at = @user.confirmed_at = Time.now.utc 
    @user.reset_password_token = hashed 
    @user.save 

    mail to: @client.contact_email, subject: "Invitation to register to Order Management System"
  end
  
end
