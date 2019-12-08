# Preview all emails at http://localhost:3000/rails/mailers/client_mails_mailer
class ClientMailsMailerPreview < ActionMailer::Preview
  
# Send email to a group of clients 
  def send_client_mail 
    emails = Client.where(cltype: 1).limit(1).pluck(:contact_email)
    email = ClientMail.first
    ClientMailsMailer.send_client_mail(emails, email)
  end  

end
