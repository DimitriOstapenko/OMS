class OrderMailerPreview < ActionMailer::Preview

# Existing Client with orders!  
  def send_confirmation 
    client = Client.second
    order = client.orders.first
    OrderMailer.send_confirmation(order)
  end

  def notify_staff
    client = Client.second
    order = client.orders.first
    OrderMailer.notify_staff(order)
  end

  def product_quantity_alert
    product = Product.first
    OrderMailer.product_quantity_alert(product,-1)
  end

end
