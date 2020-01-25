class ProductsController < ApplicationController
  
#  before_action :logged_in_user   # if this is enabled, message about activation email is not shown because of redirect
  before_action :admin_or_staff_user, only: [:new, :create, :edit, :update]
  before_action :admin_user, only: [:destroy]

  helper_method :sort_column, :sort_direction

  def new
    @product = Product.new
  end

  def index
    if current_user
      if params[:findstr] 
        @products = Product.search(params).paginate(page: params[:page])
        if @products.any?
          flash.now[:info] = "Found #{@products.count} #{'product'.pluralize(@products.count)} matching string #{params[:findstr].inspect}"
        else
          flash.now[:info] = "No products found"
        end
      else
        @products = Product.reorder(sort_column + ' ' + sort_direction, "ref_code asc").paginate(page: params[:page])
      end
    else 
      render inline: '', layout: true
    end  
  end

  def show
    @product = Product.find(params[:id]) rescue nil
    redirect_to products_path unless @product
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
      Product.where(scale: pr.scale).where(category: pr.category).update_all(price_eu: pr.price_eu, price_eu2: pr.price_eu2, price_usd: pr.price_usd)
    end
    flash[:success] = "Price rules applied to all products"
    redirect_back(fallback_location: prices_path)
  end

private
  def product_params
    params.require(:product).permit( :ref_code, :description, :brand, :category, :scale, :colour, :ctns, :release_date, :added_date,
                                     :price_eu, :price_eu2, :price_usd, :supplier, :manager, :progress, :notes ) 
  end

  def sort_column
          Product.column_names.include?(params[:sort]) ? params[:sort] : "ref_code"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end


end
