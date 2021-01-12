class ProductsController < ApplicationController
  
  include My::Docs

  before_action :logged_in_user   # if this is enabled, message about activation email is not shown because of redirect
  before_action :admin_or_staff_user, only: [:new, :create, :edit, :update, :upload_image, :image_upload]
  before_action :admin_or_su_user, only: [:destroy]

  helper_method :sort_column, :sort_direction

  def new
    @product = Product.new
  end

  def index
      found = []
      @products = Product.all
      @products = Product.where(active: true) if (current_user.client? || current_user.user?)   # Do not show disabled products to clients and world
      if params[:findstr] 
        found = @products.search(params[:findstr])
        if found.any?
          @products = found
          flash.now[:info] = "Found #{@products.count} #{'product'.pluralize(@products.count)} matching string #{params[:findstr].inspect}"
        else
          flash.now[:info] = "No products found"
        end
      end
      if params[:sort] == 'pending'  # sorting on joined table
        @products = Product.joins(:placements).where('placements.status': PENDING_ORDER).group('id').reorder(Arel.sql('sum(quantity-shipped)' + ' ' + sort_direction)).paginate(page: params[:page])
      elsif params[:sort] == 'active' 
        @products = Product.joins(:placements).where('placements.status': ACTIVE_ORDER).group('id').reorder(Arel.sql('sum(quantity-shipped)'+ ' ' + sort_direction)).paginate(page: params[:page])
      else
        @products = @products.reorder(sort_column + ' ' + sort_direction).paginate(page: params[:page])
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

  def show_inventory
    if params[:findstr]
      @products = Product.search(params[:findstr]).paginate(page: params[:page])
      if @products.any?
        flash.now[:info] = "Found #{@products.count} #{'product'.pluralize(@products.count)} matching string #{params[:findstr].inspect}"
      else
        flash.now[:info] = "No products found"
      end
    else
      @products = Product.where(active: :true).reorder(sort_column + ' ' + sort_direction, "ref_code asc").paginate(page: params[:page])
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
    clients = params[:product][:'visible_to']
    clients = clients[1..] if clients.any?  # remove empty string
    clients.each do |cl|
      client_id = cl.to_i
      next unless client_id.positive?
      client = Client.find(cl.to_i)
      @product.clients.push(client) if client
    end
    if @product.update(product_params)
      flash[:success] = "Product updated"
      redirect_back(fallback_location: products_path)
    else
      render 'edit'
    end
  end

  def disable
    @product = Product.find(params[:id])
    if @product.update_attribute( :active, false )
      flash[:success] = "Product disabled - won't be visible by client"
      redirect_back(fallback_location: products_path)
    end
  end

  def update_stock
    @product = Product.find(params[:id])
    stock = params[:product][:stock].to_i.abs rescue 0
    if @product.update_attribute(:stock, stock)
       flash[:info] = "Product : #{@product.ref_code} - updated available stock"
    else 
       flash[:danger] = "Product : #{@product.ref_code} - error updating stock"
    end
    redirect_back(fallback_location: inventories_path)
  end

  def update_delta
    @product = Product.find(params[:id])
    delta = params[:product][:delta].to_i.abs rescue 0
    @product.update_attribute(:delta, delta)
    flash[:info] = "Product : #{@product.ref_code} - updated delta amount"
    redirect_back(fallback_location: inventories_path)
  end

  def apply_price_rules
    Price.all.each do |pr|
      Product.where(scale: pr.scale).where(category: pr.category).where(manual_price: :false).
        update_all(price_eu: pr.price_eu, price_eu2: pr.price_eu2, price_eu3: pr.price_eu3, price_eu4: pr.price_eu4, 
                   price_eu5: pr.price_eu5, price_eu6: pr.price_eu6, price_usd: pr.price_usd, price_usd2: pr.price_usd2, price_cny: pr.price_cny)
    end
    flash[:success] = "Price rules applied to all products"
    redirect_back(fallback_location: prices_path)
  end

  def show_pending_orders
    @product = Product.find(params[:id])
    @placements = @product.pending_order_placements.paginate(page: params[:page])
    render 'inventories/show_pending_orders'
  end

  def show_active_orders
    @product = Product.find(params[:id])
    @placements = @product.active_order_placements.paginate(page: params[:page])
    render 'inventories/show_active_orders'
  end

  def set_pending_orders_to_shipped
    @product = Product.find(params[:id])
    @product.pending_order_placements.each do |pl|
      pl.set_to_shipped
    end
    flash[:info] = "#{@product.ref_code}: All pending placements marked as 'Shipped'"
    redirect_back(fallback_location: inventories_path)
  end

# post  
  def upload_image
    im = params[:image][:image] rescue nil
    fn = im.original_filename.upcase if im
    ref_code = Pathname(fn).basename('.JPG').to_s rescue nil

    @product = Product.find_by(ref_code: ref_code) if ref_code.present?
    if @product.present?
      @product.image = im
      if @product.save
        flash[:success] = "#{ref_code}: Image saved. Thumbnails created. Product updated"
      else
        flash.now[:danger] = @product.errors.full_messages.to_sentence
      end
    else
      flash[:warning] = "Product with Ref. code #{ref_code.inspect} does not exists. Please add it first"
    end
    redirect_to products_path
  end
  
# get: show form  
  def image_upload
    @product = Product.new
    render "upload"
  end

  # Generate inventory template in CSV
  def inventory_template
    @products = Product.where(active: true)
    respond_to do |format|
      format.html { redirect_to inventories_path }
      format.csv { send_data @products.to_csv, filename: "inventory_#{Time.now.strftime("%d_%m_%Y")}.csv" }
    end
    flash.now[:info] = "Inventory template generated. Contains #{@products.count} products"
  end

private
  def product_params
    params.require(:product).permit( :ref_code, :description, :brand, :category, :scale, :colour, :ctns, :release_date, :added_date, 
                                     :weight, :active, :price_eu, :price_eu2, :price_eu3, :price_eu4, :price_eu5, :price_eu6, 
                                     :price_usd, :price_usd2, :price_cny,  :supplier, :manager, :progress, :manual_price,  :notes, :image,
                                     :stock, :delta, visible_to: [] ) 
  end

  def sort_column
          Product.column_names.include?(params[:sort]) ? params[:sort] : "ref_code"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end


end
