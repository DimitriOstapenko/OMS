class OrdersController < ApplicationController

  before_action :logged_in_user
  before_action :admin_or_staff_user, only: [:edit, :update]
  before_action :client_user, only: [:create]
  before_action :admin_user, only: [:destroy]
  before_action :no_user_user, only: [:index]

  def index
    if current_user.client?
      @orders = current_client.orders.paginate(page: params[:page])
    else
      @orders = Order.all.paginate(page: params[:page])
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
    @order.build_placements_with_product_ids_and_quantities(@product_ids_and_quantities)

    if @order.save
      @order.reload
       flash[:info] = 'Order saved, confirmation sent'
       if Rails.env.development?
         OrderMailer.send_confirmation(@order).deliver_now
       else
         OrderMailer.delay.send_confirmation(@order).deliver_later
       end
    else
      flash[:error] = "Errors saving order: #{@order.errors.full_messages.join}"
    end
    redirect_to orders_path
  end

private

#  def order_params
#    params.require(:order).permit(:total, :user_id, :product_ids => [])
#  end
end
