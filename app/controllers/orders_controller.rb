class OrdersController < ApplicationController

  before_action :logged_in_user
  before_action :client_user, only: [:creeate, :show, :index]
  before_action :admin_or_staff_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    @orders = current_client.orders.paginate(page: params[:page])
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
    @product_ids_and_quantities = [[params[:order][:products], 5]]
    @order.build_placements_with_product_ids_and_quantities(@product_ids_and_quantities)  #(params[:order][:product_ids_and_quantities])

    if @order.save
      @order.reload
#      OrderMailer.delay.send_confirmation(order)
       flash.now[:info] = 'Order saved'
    else
      flash.now[:error] =  order.errors.full_messages 
    end
  end

private

#  def order_params
#    params.require(:order).permit(:total, :user_id, :product_ids => [])
#  end
end
