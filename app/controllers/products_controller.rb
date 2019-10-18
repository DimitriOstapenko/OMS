class ProductsController < ApplicationController
  
  before_action :logged_in_user
  before_action :admin_user, only: :destroy

  def new
    @product = Product.new
  end

  def index
    @products = Product.paginate(page: params[:page]) #, per_page: 40)
  end

  def show
    @product = Product.find(params[:id])
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

  def find
      str = params[:findstr].strip
      flash.now[:info] = "Called find with '#{params[:findstr]}' param"
      @products = myfind(str)
      if @products.any?
	 flash.now[:info] = "Found #{@products.count} #{'product'.pluralize(@products.count)} matching string #{str.inspect}"
      else
	 @products = Product.all
	 flash[:danger] = "No products found"
      end
      @products = @products.paginate(page: params[:page])
      render 'index'
  end

  def update
    if @product.update_attributes(product_params)
      flash[:success] = "Product updated"
      redirect_to products_path
    else
      render 'edit'
    end
  end


private

  def product_params
    params.require(:product).permit( :name, :type, :category, :description, :scale, :release_date, :price_eu, :price_usd ) 
  end

  # Find product by name or scale, depending on input format
  def myfind (str)
	  if str.match(/^[[:digit:]]{,6}$/)
          Product.where("scale like ?", "%#{str}%")
        elsif str.match(/^[[:graph:]]+$/)
	  Product.where("lower(name) like ?", "%#{str.downcase}%")
        else
          []
        end
  end
end
