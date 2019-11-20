class ProductsController < ApplicationController
  
  before_action :logged_in_user, except: [:index]
  before_action :admin_or_staff_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

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
        @products = Product.paginate(page: params[:page])
      end
    else 
      render html: '', layout: true
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
      redirect_to products_path
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

private
  def product_params
    params.require(:product).permit( :ref_code, :description, :brand, :category, :scale, :ctns, :release_date, :added_date,
                                     :price_eu, :price_eu2, :price_usd, :supplier, :manager, :progress, :notes ) 
  end

  # Find product by code, description or scale, depending on input format
  def myfind (str)
	if str.match(/^[[:digit:]]{,6}$/)                                 # Scale 
          Product.where("scale::text like ?", "%#{str}%")
        elsif str.match(/^[A-Z]{2,}/)                                     # Ref. Code || Description
	  Product.where("ref_code like ?", "%#{str.upcase}%") &&
	  Product.where("lower(description) like ?", "%#{str.downcase}%")
        elsif str.match(/^[[:graph:]]+$/)                                 # Description
	  Product.where("lower(description) like ?", "%#{str.downcase}%")
        else
          []
        end
  end
end
