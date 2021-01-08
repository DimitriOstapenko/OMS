class OrderMailer < ActionMailer::Base
  default from: REPLY_TO

# Send order confirmation to client  
  def send_confirmation(order)
    @order = order
    @client = @order.client
    @client.users.each do |user|
      mail to: user.email, subject: "APDOMS: Order Confirmation" rescue nil
    end
  end
    
  def send_confirmation_about_changes(order) 
    @order = order
    @client = @order.client
    @client.users.each do |user|
      mail to: user.email, subject: "APDOMS: Changes to your order #{@order.id}" rescue nil
    end
  end

# Notify staff of a new order
  def notify_staff(order)
    @order = order
    @client = @order.client
    emails = User.where('role=?', STAFF_ROLE).pluck(:email)
    mail to: emails, subject: "APDOMS: New order received" rescue nil
  end  

  def notify_staff_about_changes(order)
    @order = order
    @email = 'blah@blah.com'
    @client = @order.client
    emails = User.where('role=?', STAFF_ROLE).pluck(:email)
#    logger.debug("******************* order: #{@order.id} client:  #{@client.id} emails: #{emails.count}")
    mail to: emails, subject: "APDOMS: Changes to the order #{@order.id}"
  end

# Notify admins about cancelled order  
  def cancelled_order(order,email)
    @order = order; @email = email
    emails = User.where('role=?', ADMIN_ROLE).pluck(:email)
    mail to: emails, subject: "APDOMS: order #{order.id} was cancelled by #{email}" #rescue nil
  end

# Notify staff of a low quantity for product  
  def product_quantity_alert(product)
    @product = product
    emails = User.where('role=?', STAFF_ROLE).pluck(:email)
    mail to: emails, subject: "APDOMS: Low Product Quantity alert"
  end
end
