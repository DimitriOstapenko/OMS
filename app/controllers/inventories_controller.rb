class InventoriesController < ApplicationController
  
#  before_action :logged_in_user
  before_action :production_admin_or_staff_user #, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]
  
  helper_method :sort_column, :sort_direction

  def index
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

  def update
#    redirect_back(fallback_location: inventories_path)
  end

  def new
  end

  def create
  end

private
#  def product_params
#    params.require(:product).permit( :ref_code, :description, :brand, :category, :scale, :colour, :ctns, :release_date, :added_date,
#                                     :price_eu, :price_eu2, :price_usd, :supplier, :manager, :progress, :notes )
#  end

  def sort_column
          Product.column_names.include?(params[:sort]) ? params[:sort] : "ref_code"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end


end
