class ProductsController < ApplicationController
  
  before_action :logged_in_user
  before_action :admin_user, only: :destroy

  def new
    @product = Product.new
  end

  def index
    @products = Product.paginate(page: params[:page]) #, per_page: 40)
  end

  def find
      str = params[:findstr].strip
      @docs = myfind(str)
      if @docs.any?
	 flash.now[:info] = "Found #{@docs.count} #{'product'.pluralize(@docs.count)} matching string #{str.inspect}"
      else
	 @docs = Product.all
	 flash[:danger] = "No products found"
      end
      @products = @docs.paginate(page: params[:page])
      render 'index'
  end

  def show
  end

  def edit
  end

  def create
     @product = Product.new(product_params)
    if @product.save
       flash[:success] = "Product created"
       redirect_to @product
    else
       render 'new'
    end
  end  

  def destroy
    @product.destroy
    flash[:success] = "Product deleted"
    redirect_to products_url, page: params[:page]
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
