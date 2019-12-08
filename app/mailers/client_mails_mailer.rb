class ClientMailsMailer < ApplicationMailer

# Send email from client_mails to group of clients  
  def send_client_mail(destination,email)
    @email = email
    mail to: destination, subject: @email.title
  end

end
