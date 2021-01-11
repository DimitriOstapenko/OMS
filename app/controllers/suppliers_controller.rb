class SuppliersController < ApplicationController

  before_action :logged_in_user
  before_action :admin_or_su_user

  def new
    @supplier = Supplier.new
  end

  def index
    @suppliers = Supplier.paginate(page: params[:page]) 
  end

  def show
    @supplier = Supplier.find(params[:id])
  end

  def create
    @supplier = Supplier.new(supplier_params)
    if @supplier.save
       flash[:success] = "New supplier created"
       redirect_to suppliers_path
    else
       render 'new'
    end
  end

  def edit
    @supplier = Supplier.find(params[:id])
  end

  def find
      str = params[:findstr].strip
      flash.now[:info] = "Called find with '#{params[:findstr]}' param"
      @suppliers = myfind(str)
      if @suppliers.any?
         flash.now[:info] = "Found #{@suppliers.count} #{'supplier'.pluralize(@suppliers.count)} matching string #{str.inspect}"
      else
         @suppliers = Supplier.all
         flash[:danger] = "No suppliers found"
      end
      @suppliers = @suppliers.paginate(page: params[:page])
      render 'index'
  end

  def update
    @supplier = Supplier.find(params[:id])
    if @supplier.update(supplier_params)
      flash[:success] = "Supplier updated"
      redirect_to suppliers_path
    else
      render 'edit'
    end
  end

private
  def supplier_params
    params.require(:supplier).permit( :company, :fname, :lname, :email, :phone )
  end

  # Find supplier by code, description or scale, depending on input format
  def myfind (str)
        if str.match(/^[[:graph:]]+$/)                                 # Last Name
          Supplier.where("lower(lname) like ?", "%#{str.downcase}%")
        else
          []
        end
  end


end
