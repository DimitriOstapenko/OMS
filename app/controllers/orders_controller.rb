class OrdersController < ApplicationController

  include My::Docs
  helper_method :sort_column, :sort_direction

  before_action :init, only: [:show, :edit, :update, :download, :download_po, :download_invoice, :cancel, :destroy, :set_to_shipped, :mark_as_paid ]
  before_action :logged_in_user
  before_action :production_admin_or_staff_user, only: [:edit, :update]
  before_action :client_user, only: [:create]
  before_action :admin_or_su_user, only: [:destroy]
  before_action :no_user_user, only: [:index]
  before_action :verify_order_geo, only: [:show, :edit, :update]

  def index
    keyword = params[:findstr]; search_results = []
    @status = params[:status]
    @client = current_client if current_user.client?  
    @orders = Order.all
    @orders = Order.where(geo: GEO_CN) if current_user.production?
    @orders = @client.orders if @client.present?
    @orders = @orders.where(status: @status) if @status.present?
    @status ||= 9

    search_results = Order.search(keyword,@client) if keyword
    @orders = search_results if search_results.any?
    @orders_ = @orders
    @orders = @orders.reorder(sort_column + ' ' + sort_direction, "created_at desc").paginate(page: params[:page]) 
  end 

  def show
    @client = @order.client
    @placements = @order.placements
  end

  def new
    @client = current_client
    @order = Order.new
    @placement = @order.placements.new
  end

  def create
    @client = current_client
    @order = @client.orders.build
    @order.geo = client_geo  # app controller
    @order.user_id = current_user.id
    @product_ids_and_quantities = get_cart #[[params[:order][:products], params[:order][:quantity]]]
    if @order.build_placements_with_product_ids_and_quantities?(@product_ids_and_quantities) && @order.save
       @order.reload
       clear_cart
       flash[:info] = 'Order saved, confirmation sent'
     else
       flash[:danger] = "Errors saving order: #{@order.errors.full_messages.join} client: #{@client.name} : #{@product_ids_and_quantities.inspect}"
    end

    redirect_to orders_path
  end

  def edit
  end

  def update
    @order.user_id ||= current_user.id
    if @order.update_attributes(order_params)
      flash[:success] = "Order #{@order.id} updated"
      redirect_to orders_path
    else
      render 'edit'
    end
  end

# Destroy Order, update product quantity  
  def destroy
    if @order.status == PENDING_ORDER
      @order.placements.each do |pl|
        pl.ppo.delete_pdf if pl.ppo.present?
      end 
      @order.destroy
      @order.delete_pdfs
      flash[:success] = "Order deleted"
    else
      flash[:warning] = "Cannot delete Active/Shipped orders."
    end
    redirect_to orders_path
  end

# Cancel Order, update inventory, regenerate PPO. Keep cancelled order in the system.
  def cancel
    email = current_user.email rescue ''
    @order.cancel(email)
    flash[:warning] = "Order #{@order.id} was canceled."
    redirect_to orders_path
  end

# Generate CSV file of all orders up till now
  def export
    @orders = Order.all
    send_data @orders.to_csv, filename: "orders-#{Date.today}.csv"
    flash.now[:info] = 'Orders exported to CSV file'
  end

# Generate PDF PO  
  def download_po
    if @order.po_file_present?
      send_file @order.po_filespec,
                filename: @order.po_number,
                type: "application/pdf",
                disposition: :attachment
      else
        @order.regenerate_po
        flash[:info] = 'File regenerated'
        redirect_to download_po_order_path(@order)
    end 
  end

# Generate PDF invoice  
  def download_invoice
    if @order.invoice_file_present?
      send_file @order.inv_filespec,
                filename: @order.inv_number,
                type: "application/pdf",
                disposition: :attachment
    else
      @order.regenerate_invoice
      flash[:info] = 'File regenerated'
      redirect_to download_invoice_order_path(@order)
    end 
  end

# Set all placements to "Shipped"; Regenerate PPO and mark Order as "Shipped"
  def set_to_shipped
    @order.placements.each do |pl|
      pl.set_to_shipped
    end

    flash[:info] = "Order #{@order.id} is set to Shipped"
    redirect_to orders_path 
  end

# Mark this order as paid and set all placements to active to prevent further changes to quantities
  def mark_as_paid
    @order.update_attribute(:status, ACTIVE_ORDER)
    @order.update_attribute(:paid, true)
    @order.placements.each do |pl|
      pl.set_to_active if pl.pending?
    end
    flash[:info] = "Order #{@order.id} is marked as paid"
    redirect_to orders_path 
  end

private
  def init
    @order = Order.find(params[:id]) rescue nil
    (flash[:warning] = "Order not found"; redirect_to orders_path) unless @order
  end

  def order_params
    params.require(:order).permit(:web_id, :status, :po_number, :inv_number, :delivery_by, :terms, 
                                  :notes, :pmt_method, :discount, :user_id, :paid, :total, :weight, :geo) 
  end

  def sort_column
    Order.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end


end
