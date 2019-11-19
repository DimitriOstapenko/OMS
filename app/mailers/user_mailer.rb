class UserMailer < ApplicationMailer

  def new_registration(user)
    @user = user
    email = User.where('role=?', ADMIN_ROLE).first.email rescue REPLYTO
    mail to: email, subject: "New user registration"
  end

end
