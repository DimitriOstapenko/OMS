class ProductsController < ApplicationController
  
  include My::Docs

#  before_action :logged_in_user   # if this is enabled, message about activation email is not shown because of redirect
  before_action :admin_or_staff_user, only: [:new, :create, :edit, :update]
  before_action :admin_user, only: [:destroy]

  helper_method :sort_column, :sort_direction

  def new
    @product = Product.new
  end

  def index
    if current_user
      redirect_to inventories_path if current_user.production?
      found = []
      @products = Product.all
      @products = Product.where(active: true) if (current_user.client? || current_user.user?)   # Do not show disabled products to clients and world
      if params[:findstr] 
        found = @products.search(params)
        if found.any?
          @products = found
          flash.now[:info] = "Found #{@products.count} #{'product'.pluralize(@products.count)} matching string #{params[:findstr].inspect}"
        else
          flash.now[:info] = "No products found"
        end
      end
      @products = @products.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
    else 
      redirect_to home_path
    end  
  end

  def show
    @product = Product.find(params[:id]) rescue nil
    redirect_to products_path unless @product
    respond_to do |format|
      format.html #{ redirect_to products_path }  # Show only js version
      format.js
    end
  end

  def create
    @product = Product.new(product_params)
    if @product.save
       flash[:success] = "New product created"
       redirect_to products_path
    else
       render 'new'
    end
  end

  def destroy
    Product.find(params[:id]).destroy
    flash[:success] = "Product deleted"
    redirect_to products_path
  end

  def edit
    @product = Product.find(params[:id])
  end

  def update
    @product = Product.find(params[:id])
    if @product.update_attributes(product_params)
      flash[:success] = "Product updated"
      redirect_back(fallback_location: products_path)
    else
      render 'edit'
    end
  end

  def update_quantity
    @product = Product.find(params[:id])
    @product.update_attribute(:quantity, params[:product][:quantity])
    flash[:info] = "Product : #{@product.ref_code} - updated quantity: #{@product.quantity}"
    redirect_back(fallback_location: inventories_path)
  end

  def apply_price_rules
    Price.all.each do |pr|
      Product.where(scale: pr.scale).where(category: pr.category).where(manual_price: :false).
        update_all(price_eu: pr.price_eu, price_eu2: pr.price_eu2, price_eu3: pr.price_eu3, price_eu4: pr.price_eu4, 
                   price_eu5: pr.price_eu5, price_eu6: pr.price_eu6, price_usd: pr.price_usd, price_usd2: pr.price_usd2)
    end
    flash[:success] = "Price rules applied to all products"
    redirect_back(fallback_location: prices_path)
  end

# Set Placements across all orders for this product to Back Order, Generate PPO
  def set_back_order
    @product = Product.find(params[:id])
    @product.pending_order_placements.each do |pl|
       pl.update_attribute(:status, BACKORDER_PLACEMENT)
    end 
    pdf = build_ppo_pdf(@product) # in My::Docs
    pdf.render_file @product.active_ppo.filespec
    flash[:info] = "Back order created for '#{@product.ref_code}'"
    redirect_to inventories_path
  end

  def show_pending_orders
    @product = Product.find(params[:id])
    @placements = @product.pending_order_placements.paginate(page: params[:page])
    render 'inventories/show_pending_orders'
  end
  
  def show_back_orders
    @product = Product.find(params[:id])
    @placements = @product.back_order_placements.paginate(page: params[:page])
    render 'inventories/show_back_orders'
  end
  
# Set status of all placements on back order to shipped
  def set_back_order_to_shipped
    @product = Product.find(params[:id])
    @product.back_order_placements.each do |pl|
       pl.update_attribute(:status, SHIPPED_PLACEMENT)
    end
    @product.active_ppo.update_attribute(:status, ARCHIVED_PPO)
    flash[:info] = "All items in back order for #{@product.ref_code} set to Shipped"
    redirect_to inventories_path
  end

private
  def product_params
    params.require(:product).permit( :ref_code, :description, :brand, :category, :scale, :colour, :ctns, :release_date, :added_date, 
                                     :weight, :quantity, :active, :price_eu, :price_eu2, :price_eu3, :price_eu4, :price_eu5, :price_eu6, 
                                     :price_usd, :price_usd2, :supplier, :manager, :progress, :manual_price,  :notes ) 
  end

  def sort_column
          Product.column_names.include?(params[:sort]) ? params[:sort] : "ref_code"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end


end
