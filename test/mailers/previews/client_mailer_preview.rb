# Preview all emails at http://localhost:3000/rails/mailers/client_mailer
class ClientMailerPreview < ActionMailer::Preview

  # Send invitation to register to client
  def send_invite_to_register
    client = Client.first
    user = User.first
    ClientMailer.send_invite_to_register(client,user)
  end


end
