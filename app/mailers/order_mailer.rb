class OrderMailer < ActionMailer::Base
  default from: REPLY_TO

  def send_confirmation(order)
    @order = order
    @client = @order.client
    mail to: @client.user.email, subject: "LS Collectibles Order Confirmation"
  end
end
