class UserMailer < ApplicationMailer

# Send new registration notification to staff members  
  def new_registration(user)
    @user = user
    emails = User.where('role=?', ADMIN_ROLE).pluck(:email) rescue REPLY_TO
    mail to: emails, subject: "New user registration"
  end

  def new_product(product)
    @product = product
    emails = User.where('role=? or role=?', ADMIN_ROLE,STAFF_ROLE).pluck(:email) rescue REPLY_TO
    mail to: emails, subject: "New product created"
  end

end
