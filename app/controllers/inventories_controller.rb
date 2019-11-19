class InventoriesController < ApplicationController
  
  before_action :logged_in_user
  before_action :admin_or_staff_user #, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
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
  end 

  def update
    @product = Product.find(params[:id])
    @product.update_attribute(:quantity, params[:quantity])
    flash[:info] = "Product : #{@product.ref_code} - updated quantity: #{@product.quantity}"
    redirect_back(fallback_location: inventories_path)
  end

  def new
  end

  def create
  end

end
