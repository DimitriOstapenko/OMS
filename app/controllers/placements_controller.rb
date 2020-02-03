class PlacementsController < ApplicationController

  before_action :logged_in_user
  before_action :client_user, only: [:create]
  before_action :admin_or_staff_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    @order = Order.find(params[:order_id])
    @client = @order.client
    @placements = @order.placements.paginate(page: params[:page])
  end

  def show
    @placement = Placement.find(params[:id])
  end

  def add_product
# app_controller    
    quantity = params[:quantity] || params[:placement][:quantity]
    id = params[:id] || params[:placement][:id]
    if add_to_cart?(id, quantity)
      flash[:notice] = 'Product added to shopping cart'
    else
      flash[:danger] = "Error adding product to cart.#{params.inspect}"
    end
    redirect_back(fallback_location: products_path) 
  end

  def cart
    @products = get_cart
    @client = current_client
  end

  def empty_cart
    clear_cart
    redirect_back(fallback_location: products_path)
  end


end
