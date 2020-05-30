class OrdersController < ApplicationController

  include My::Docs
  helper_method :sort_column, :sort_direction

  before_action :logged_in_user
  before_action :production_admin_or_staff_user, only: [:edit, :update]
  before_action :client_user, only: [:create]
  before_action :admin_user, only: [:destroy]
  before_action :no_user_user, only: [:index]

  def index
    keyword = params[:findstr]; search_results = []
    @client = current_client if current_user.client?  
    if @client.present?
      @orders = @client.orders
    else
      @orders = Order.all
    end
    search_results = Order.search(keyword,@client) if keyword
    @orders = search_results if search_results.any?
    @orders = @orders.reorder(sort_column + ' ' + sort_direction, "created_at desc").paginate(page: params[:page]) 
    @grand_total = @orders.sum{|o| o[:total]*o.client.fx_rate}

    flash[:info] = "#{search_results.count} orders found" if keyword
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
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
    if @order.update_attributes(order_params)
      flash[:success] = "Order #{@order.id} updated"
#      redirect_back(fallback_location: orders_path)
      redirect_to orders_path
    else
      render 'edit'
    end
  end

# Destroy Order, update inventory  
  def destroy
    @order =  Order.find(params[:id])
    @order.placements.each do |pl|
      pl.product.update_attribute(:quantity, pl.quantity + pl.product.quantity) if @order.status == PENDING_ORDER
      pl.ppo.regenerate if pl.ppo.present?
    end 
    @order.destroy
    flash[:success] = "Order deleted. Inventory adjusted. PPOs regenerated"
    redirect_to orders_path
  end

# Cancel Order, update inventory, regenerate PPO. Keep cancelled order in the system.
  def cancel
    @order = Order.find(params[:id])
    @order.placements.each do |pl|
       pl.update_attribute(:status, CANCELLED_ORDER)
       pl.product.update_attribute(:quantity, pl.quantity + pl.product.quantity) if @order.status == PENDING_ORDER
       pl.ppo.regenerate if pl.ppo.present?
    end 
    @order.update_attribute(:status, CANCELLED_ORDER) 
    flash[:warning] = 'Order was cancelled. Inventory adjusted. PPOs regenerated'
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
    @order = Order.find( params[:id] ) rescue nil
   
    if @order
       if @order.po_file_present?
          send_file @order.po_filespec,
                    filename: @order.po_number,
                    type: "application/pdf",
                    disposition: :attachment
          else
            pdf = build_po(@order)
            pdf.render_file @order.po_filespec
            flash[:info] = 'File regenerated'
            redirect_to download_po_order_path(@order)
       end 
       else
        flash[:warning] = 'Order does not exist'
        redirect_to orders_path
    end
  end

# Generate PDF invoice  
  def download_invoice
   @order = Order.find( params[:id] ) rescue nil
   if @order 
     if @order.invoice_file_present?
        send_file @order.inv_filespec,
                  filename: @order.inv_number,
                  type: "application/pdf",
                  disposition: :attachment
      else
        pdf = build_invoice(@order)
        pdf.render_file @order.inv_filespec
        flash[:info] = 'File regenerated'
        redirect_to download_invoice_order_path(@order)
      end 
    else
      flash[:warning] = 'Order does not exist'
      redirect_to orders_path
    end
  end
  

private

  def order_params
    params.require(:order).permit(:web_id, :status, :po_number, :inv_number, :delivery_by, :terms, :notes, :pmt_method, :shipping, :discount, :tax)
  end

  def sort_column
          Order.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
