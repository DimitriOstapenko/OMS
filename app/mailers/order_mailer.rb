class OrderMailer < ActionMailer::Base
  default from: REPLY_TO

# Send order confirmation to client  
  def send_confirmation(order)
    @order = order
    @client = @order.client
    mail to: @client.user.email, subject: "LS Collectibles Order Confirmation"
  end

# Notify staff of a new order
  def notify_staff(order)
    @order = order
    @client = @order.client
    emails = User.where('role=?', STAFF_ROLE).pluck(:email)
    mail to: emails, subject: "OMS New order just received"
  end  

# Notify staff of a low quantity for product  
  def product_quantity_alert(product, newqty)
    @product = product
    @product.quantity = newqty
    emails = User.where('role=?', STAFF_ROLE).pluck(:email)
    mail to: emails, subject: "OMS Low Product Quantity alert"
  end
end
