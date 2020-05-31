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
    flash[:danger] = "Error adding product to cart. #{params.inspect}" unless add_to_cart?(id, quantity)
    redirect_back(fallback_location: products_path) 
  end

 # Remove product from cart
  def delete_product
    id = params[:id] || params[:placement][:id]
    flash[:danger] = "Error deleting product from cart.#{params.inspect}" unless del_from_cart?(id)
    redirect_back(fallback_location: products_path) 
  end

# Update number of pieces for the product - Readd product
  def update_product_qty
    id = params[:id] || params[:placement][:id]
    quantity = params[:quantity] || params[:placement][:quantity]
    if quantity.to_i.positive? && del_from_cart?(id) 
       flash[:danger] = "Error updating number of product in cart. Only positive numbers are allowed." unless add_to_cart?(id, quantity)
    end
    redirect_back(fallback_location: products_path) 
  end

  def cart
    @products = get_cart
    @client = current_client
  end

  def empty_cart
    clear_cart
#    redirect_back(fallback_location: products_path)
    redirect_to products_path
  end

  def set_to_shipped
    @placement = Placement.find(params[:id])
    @placement.update_attribute(:status, SHIPPED_ORDER)
    @placement.order.update_attribute(:status, SHIPPED_ORDER) if @placement.order.all_placements_shipped?
    if @placement.ppo.present?
      @placement.ppo.regenerate
      @placement.ppo.update_attribute(:status, ARCHIVED_PPO)
    end
    flash[:info] = "Placement is set to Shipped"
    redirect_back(fallback_location: inventories_path)
  end

end
