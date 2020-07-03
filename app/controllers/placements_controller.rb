class PlacementsController < ApplicationController

  before_action :logged_in_user
  before_action :client_user, only: [:create]
  before_action :admin_or_staff_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    @order = Order.find(params[:order_id])
    @client = @order.client
    @placements = @order.placements #.paginate(page: params[:page])
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

# Set shipped attribute;  
  def update_shipped
    @placement = Placement.find(params[:id])
    shipped = params[:placement][:shipped].to_i.abs rescue 0
    shipped = @placement.quantity if shipped > @placement.quantity 
    prev_shipped = @placement.shipped
    @placement.product.update_attribute(:quantity, @placement.product.quantity + shipped - prev_shipped)
    if shipped && @placement.update_attribute(:shipped, shipped)
       flash[:success] = "Placement updated " 
       if shipped == @placement.quantity
#         redirect_to set_to_shipped_order_placement_path(@placement.order,@placement) 
          @placement.set_to_shipped
          redirect_back(fallback_location: inventories_path)
       else
         @placement.update_attribute(:status, ACTIVE_ORDER)
         @placement.order.update_attribute(:status, ACTIVE_ORDER)
         redirect_back(fallback_location: inventories_path)
       end
    else 
      flash[:warning] = 'Error updating placement'
      redirect_back(fallback_location: inventories_path)
    end
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

# Set placement status to "Shipped"; Regenerate PPO and mark Order as "Shipped" if all placements are shipped
  def set_to_shipped
    @placement = Placement.find(params[:id]); msg = '';
    @placement.set_to_shipped
    msg = "Order #{@placement.order_id} is set to Shipped" if @placement.order.all_placements_shipped?
    msg << "#{@placement.product.ref_code}: Placement is set to Shipped; "
    flash[:info] = msg
    if request.referer.match(/orders/)
      redirect_to order_placements_path(@placement.order) 
#    elsif request.referer.match(/show_placements/)
#      redirect_to show_placements_ppo_path(@placement.ppo)
    else
     redirect_to product_ppos_path(@placement.product)
    end
  end

private
#  def placement_params
#    params.require(:placement).permit( :order_id, :product_id, :quantity, :price, :status, :ppo_id, :shipped, :to_ship, :last_pl_id)
#  end  

end
