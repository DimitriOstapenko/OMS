class PlacementsController < ApplicationController

  before_action :logged_in_user
#  before_action :client_user, only: [:create, :update, :destroy]
#  before_action :admin_or_staff_user, only: [:edit, :update, :destroy]
#  before_action :admin_or_su_user, only: [:destroy]

  def index
    @order = Order.find(params[:order_id])
    @client = @order.client
    @placements = @order.placements #.paginate(page: params[:page])
  end

  def show
    @placement = Placement.find(params[:id])
  end

# Add product to shopping cart  
  def add_product
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

# Update number of pieces for the product in Cart
  def update_product_qty
    id = params[:id] || params[:placement][:id]
    quantity = params[:quantity] || params[:placement][:quantity]
    if quantity.to_i.positive? && del_from_cart?(id) 
       flash[:danger] = "Error updating number of items in cart." unless add_to_cart?(id, quantity)
    end
    redirect_back(fallback_location: products_path) 
  end

# update this placement
  def update
    @placement = Placement.find(params[:id])
    new_qty = params[:placement][:quantity].to_i  rescue 0
    email = current_user.email rescue ''

    if new_qty.zero?
      @placement.order.last_change_by = email
      @placement.cancel(email)
      flash[:warning] = "Placement cancelled" 
    elsif @placement.update(placement_params)
      flash[:success] = "Placement updated" 
      @placement.order.last_change_by = email
      @placement.delete_pdfs
      @placement.order.save!
    else 
      flash[:danger] = "Error updating placement" 
    end
    redirect_back(fallback_location: order_path(@placement.order))
  end 

# Set shipped attribute;  
  def update_shipped
    @placement = Placement.find(params[:id])
    shipped = params[:placement][:shipped].to_i.abs rescue 0
    shipped = @placement.quantity if shipped > @placement.quantity 
    if shipped && @placement.update_attribute(:shipped, shipped)
       @placement.order.update_attribute(:status, ACTIVE_ORDER)
       flash[:success] = "Placement updated " 
       if shipped == @placement.quantity
          @placement.set_to_shipped
          redirect_back(fallback_location: inventories_path)
       else
         @placement.update_attribute(:status, ACTIVE_ORDER)
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
    redirect_to products_path
  end

# Set placement status to "Shipped"; Regenerate PPO and mark Order as "Shipped" if all placements are shipped
#  def set_to_shipped
#    @placement = Placement.find(params[:id]); msg = '';
#    @placement.set_to_shipped
#    msg = "Order #{@placement.order_id} is set to Shipped" if @placement.order.all_placements_shipped?
#    msg << "#{@placement.product.ref_code}: Placement is set to Shipped; "
#    flash[:info] = msg
#    if request.referer.match(/orders/)
#      redirect_to order_path(@placement.order) 
#    else
#     redirect_to product_ppos_path(@placement.product)
#    end
#  end

  def destroy
    @placement = Placement.find(params[:id])
    @order = @placement.order
    @placement.destroy
    @order.delete_pdfs
    if @order.placements.count < 1
      flash[:success] = "Placement & order deleted"
      @order.destroy 
      redirect_to orders_path
    else 
      flash[:success] = "Placement deleted"
      @placement.ppo.delete_pdf if @placement.ppo.present?
      @order.save
      redirect_back(fallback_location: @order)
    end
  end

  # Cancel placement. Cancel order if all placements deleted.  Keep in the db 
  def cancel
    @placement = Placement.find(params[:id])
    email = current_user.email rescue ''
    @placement.cancel(email)
    
    if @placement.order.all_placements_cancelled? 
      flash[:warning] = "Order #{@placement.order_id} was cancelled."
    else
      flash[:warning] = "Placement cancelled."
    end

    redirect_back(fallback_location: @order)
  end


private
  def placement_params
    params.require(:placement).permit( :order_id, :product_id, :quantity, :price, :status, :ppo_id, :shipped, :to_ship, :packing_list_id)
  end  

end
