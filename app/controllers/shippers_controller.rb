class ShippersController < ApplicationController
  before_action :set_shipper, only: [:show, :edit, :update, :destroy]
  before_action :logged_in_user
  before_action :admin_or_su_user 

  def new
    @shipper = Shipper.new
  end

  def index
    @shippers = Shipper.paginate(page: params[:page])
  end

  def show
  end

  def create
    @shipper = Shipper.new(shipper_params)
    if @shipper.save
       flash[:success] = "New shipper created"
       redirect_to shippers_path
    else
       render 'new'
    end
  end

  def edit
  end

  def update
    if @shipper.update(shipper_params)
      flash[:success] = "Shipper updated"
      redirect_to shippers_path
    else
      render 'edit'
    end
  end

private
  def shipper_params
    params.require(:shipper).permit( :name, :email, :phone, :website )
  end

  def set_shipper
    @shipper = Shipper.find(params[:id])
  end

end
