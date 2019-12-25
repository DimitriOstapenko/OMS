class OrdersController < ApplicationController

  include My::Forms

  before_action :logged_in_user
  before_action :admin_or_staff_user, only: [:edit, :update]
  before_action :client_user, only: [:create]
  before_action :admin_user, only: [:destroy]
  before_action :no_user_user, only: [:index]

  def index
    client_id = params[:order][:client_id] rescue nil
    @client = Client.find(client_id) if client_id.present?
    @client = current_client if current_user.client?  
    if @client.present?
      @orders = @client.orders
      @orders = @orders.paginate(page: params[:page])
    else
      @orders = Order.all
      @orders = @orders.paginate(page: params[:page])
    end
    @grand_total = @orders.sum{|o| o[:total]*o.client.fx_rate}
  end 

  def show
    @order = current_client.orders.find(params[:id]) rescue nil
  end

  def new
    @client = current_client
    @order = Order.new
    @placement = @order.placements.new
  end

  def create
    @client = current_client
    @order = @client.orders.build
    @product_ids_and_quantities = get_cart #[[params[:order][:products], params[:order][:quantity]]]
    if @order.build_placements_with_product_ids_and_quantities?(@product_ids_and_quantities) &&
       @order.save
       @order.reload
       clear_cart
       flash[:info] = 'Order saved, confirmation sent'
#       OrderMailer.send_confirmation(@order).deliver_later
#       OrderMailer.notify_staff(@order).deliver_now
     else
       flash[:danger] = "Errors saving order: #{@order.errors.full_messages.join}"
    end

    redirect_to orders_path
  end

  def edit
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    if @order.update_attributes(order_params)
      flash[:success] = "Order #{@order.id} updated"
      redirect_back(fallback_location: orders_path)
    else
      render 'edit'
    end
  end

  def export
    @orders = Order.all
    send_data @orders.to_csv, filename: "orders-#{Date.today}.csv"
    flash.now[:info] = 'Orders exported to CSV file'
  end

  def download_po
   @order = Order.find( params[:id] ) rescue nil
   redirect_to orders_path unless @order
   
   if @order.po_file_present?
      send_file @order.po_filespec,
                filename: @order.po_number,
                type: "application/pdf",
                disposition: :attachment
    else
      pdf = build_po(@order)
      pdf.render_file @order.po_filespec
      redirect_to download_po_order_path(@order), alert: "File regenerated"
    end 
  end

  def download_invoice
   @order = Order.find( params[:id] ) rescue nil
   redirect_to orders_path unless @order
   
   if @order.invoice_file_present?
      send_file @order.inv_filespec,
                filename: @order.inv_number,
                type: "application/pdf",
                disposition: :attachment
    else
      pdf = build_invoice(@order)
      pdf.render_file @order.inv_filespec
      redirect_to download_invoice_order_path(@order), alert: "File regenerated"
    end 
  end
  

private

  def order_params
    params.require(:order).permit(:web_id, :status, :inv_number, :delivery_by, :terms, :notes)
  end
end
