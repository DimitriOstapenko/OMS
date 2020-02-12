class UserMailer < ApplicationMailer

# Send new registration notification to staff members  
  def new_registration(user)
    @user = user
    emails = User.where('role=?', STAFF_ROLE).pluck(:email) rescue REPLYTO
    mail to: emails, subject: "New user registration"
  end

end
