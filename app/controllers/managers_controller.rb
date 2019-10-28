class ManagersController < ApplicationController

  before_action :logged_in_user
  before_action :admin_user #, only: [:destroy]

  def new
    @manager = Manager.new
  end

  def index
    @managers = Manager.paginate(page: params[:page])
  end

  def show
    @manager = Manager.find(params[:id])
  end

  def create
    @manager = Manager.new(manager_params)
    if @manager.save
       flash[:success] = "New manager created"
       redirect_to managers_path
    else
       render 'new'
    end
  end

  def edit
    @manager = Manager.find(params[:id])
  end

  def find
    str = params[:findstr].strip
    flash.now[:info] = "Called find with '#{params[:findstr]}' param"
    @managers = myfind(str)
    if @managers.any?
      flash.now[:info] = "Found #{@managers.count} #{'manager'.pluralize(@managers.count)} matching string #{str.inspect}"
    else
      @managers = Manager.all
      flash[:danger] = "No managers found"
    end
      @managers = @managers.paginate(page: params[:page])
      render 'index'
  end

  def update
    @manager = Manager.find(params[:id])
    if @manager.update_attributes(manager_params)
      flash[:success] = "Manager updated"
      redirect_to managers_path
    else
      render 'edit'
    end
  end

private
  def manager_params
    params.require(:manager).permit( :fname, :lname, :email, :phone )
  end

  # Find manager by code, description or scale, depending on input format
  def myfind (str)
        if str.match(/^[[:graph:]]+$/)                                 # Last Name
          Manager.where("lower(lname) like ?", "%#{str.downcase}%")
        else
          []
        end
  end

end
