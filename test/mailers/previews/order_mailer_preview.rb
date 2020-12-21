class OrderMailerPreview < ActionMailer::Preview

# Existing Client with orders!  
  def send_confirmation 
    order = Order.first
    OrderMailer.send_confirmation(order)
  end

  def send_confirmation_about_changes
    order = Order.last
    OrderMailer.send_confirmation_about_changes(order)
  end

  def notify_staff
    order = Order.first
    OrderMailer.notify_staff(order)
  end

  def notify_staff_about_changes
    order = Order.last
    OrderMailer.notify_staff_about_changes(order)
  end

  def cancelled_order
    order = Order.first
    OrderMailer.cancelled_order(order, 'dosta@me.com')
  end

  def product_quantity_alert
    product = Product.first
    OrderMailer.product_quantity_alert(product)
  end

end
