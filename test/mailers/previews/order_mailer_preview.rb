class OrderMailerPreview < ActionMailer::Preview
  def send_confirmation 
#    order = OpenStruct.new(email: "demo@example.com", name: "John Doe")
    client = Client.find(2328)
    order = client.orders.first
    OrderMailer.send_confirmation(order)
  end
end
