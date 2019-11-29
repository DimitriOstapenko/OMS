class PlacementsController < ApplicationController

  before_action :logged_in_user
  before_action :client_user, only: [:create]
  before_action :admin_or_staff_user, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    @order = Order.find(params[:order_id])
    @client = @order.client
    @placements = @order.placements.paginate(page: params[:page])
  end

  def show
    @placement = Placement.find(params[:id])
  end

end
