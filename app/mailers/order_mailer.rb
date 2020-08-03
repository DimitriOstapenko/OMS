class OrderMailer < ActionMailer::Base
  default from: REPLY_TO

# Send order confirmation to client  
  def send_confirmation(order)
    @order = order
    @client = @order.client
    @client.users.each do |user|
      mail to: user.email, subject: "OMS Order Confirmation" rescue nil
    end
  end

# Notify staff of a new order
  def notify_staff(order)
    @order = order
    @client = @order.client
    emails = User.where('role=?', STAFF_ROLE).pluck(:email)
    mail to: emails, subject: "OMS New order just received" rescue nil
  end  

# Notify admins about cancelled order  
  def cancelled_order(order,email)
    @order = order; @email = email
    emails = User.where('role=?', ADMIN_ROLE).pluck(:email)
    mail to: emails, subject: "OMS order #{order.id} was cancelled by #{email}" #rescue nil
  end

# Notify staff of a low quantity for product  
  def product_quantity_alert(product)
    @product = product
    emails = User.where('role=?', STAFF_ROLE).pluck(:email)
    mail to: emails, subject: "OMS Low Product Quantity alert"
  end
end
