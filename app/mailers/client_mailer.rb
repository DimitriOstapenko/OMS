# Send emails to single client
class ClientMailer < ApplicationMailer
  
  def send_invite_to_register(client)
    @client = client
    mail to: @client.contact_email, subject: "Invitation to register to Order Management System"
  end
  
end
