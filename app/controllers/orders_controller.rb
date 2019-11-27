class OrdersController < ApplicationController

  before_action :logged_in_user
  before_action :admin_or_staff_user, only: [:edit, :update]
  before_action :client_user, only: [:create]
  before_action :admin_user, only: [:destroy]
  before_action :no_user_user, only: [:index]

  def index
    if current_user.client?
      @orders = current_client.orders
      @grand_total = @orders.sum{|o| o[:total]}
      @orders = @orders.paginate(page: params[:page])
    else
      @orders = Order.all
      @grand_total = @orders.sum{|o| o[:total]}
      @orders = @orders.paginate(page: params[:page])
    end
  end 

  def show
    @order = current_client.orders.find(params[:id])
  end

  def new
    @client = current_client
    @order = Order.new
  end

  def create
    @client = current_client
    @order = @client.orders.build
    @placement = @order.placements.first
    @product_ids_and_quantities = [[params[:order][:products], params[:order][:quantity]]]
    if @order.build_placements_with_product_ids_and_quantities?(@product_ids_and_quantities) &&
       @order.save
        po_number = 'PO'+Time.now.strftime("%Y%m%d")+'-'+@order.id.to_s
        @order.update_attribute(:po_number, po_number)
        @order.reload
        flash[:info] = 'Order saved, confirmation sent'
        OrderMailer.send_confirmation(@order).deliver_later
        OrderMailer.notify_staff(@order).deliver_now
      else
        flash[:danger] = "Errors saving order: #{@order.errors.full_messages.join}"
    end

    redirect_to orders_path
  end

  def export
    @orders = Order.all
    send_data @orders.to_csv, filename: "orders-#{Date.today}.csv"
    flash.now[:info] = 'Orders exported to CSV file'
  end

private

#  def order_params
#    params.require(:order).permit(:total, :user_id, :product_ids => [])
#  end
end
