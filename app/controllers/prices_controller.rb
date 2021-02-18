class PricesController < ApplicationController
  
  before_action :logged_in_user
  before_action :admin_or_staff_user
 
  def new
    @price = Price.new
  end

  def index
    @prices = Price.all
    filter = params[:price]
    if filter
      @scale = filter[:scale]
      @brand = filter[:brand]
      @category = filter[:category]
    end 

    @prices = @prices.where(scale: @scale) if @scale.present?
    @prices = @prices.where(brand: @brand) if @brand.present?
    @prices = @prices.where(category: @category) if @category.present?

    @table_note = TableNote.find_by(table_name: 'prices') || TableNote.create('table_name': 'prices')
    @prices = @prices.paginate(page: params[:page])
#    flash[:info] = "scale: #{@scale} brand: #{@brand} cat: #{@category}"
  end

  def create
    @price = Price.new(price_params)
    if @price.save
       flash[:success] = "New price rule created"
       redirect_to prices_path
    else
       render 'new'
    end
  end
  
  def edit
    @price = Price.find(params[:id])
  end

  def update
    @price = Price.find(params[:id])
    if @price.update(price_params)
      flash[:success] = "Price rule updated"
      redirect_to prices_path
    else
      render 'edit'
    end
  end

  def show
    @price = Price.find(params[:id])
    redirect_to prices_path unless @price
  end

  def destroy
    Price.find(params[:id]).destroy
    flash[:success] = "Price rule deleted"
    redirect_to prices_path
  end


private
  def price_params
    params.require(:price).permit( :scale, :category, :brand, :price_eu, :price_eu2, :price_eu3, :price_eu4, :price_eu5, :price_eu6, :price_usd, :price_usd2, :price_cny )
  end  

end
