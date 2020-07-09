class OrdersController < ApplicationController

  include My::Docs
  helper_method :sort_column, :sort_direction

  before_action :logged_in_user
  before_action :production_admin_or_staff_user, only: [:edit, :update]
  before_action :client_user, only: [:create]
  before_action :admin_or_su_user, only: [:destroy]
  before_action :no_user_user, only: [:index]

  def index
    keyword = params[:findstr]; search_results = []
    @status = params[:status]
    @client = current_client if current_user.client?  
    @orders = Order.all
    @orders = @client.orders if @client.present?
    @orders = @orders.where(status: @status) if @status.present?
    @status ||= 9

    search_results = Order.search(keyword,@client) if keyword
    @orders = search_results if search_results.any?
    @orders = @orders.reorder(sort_column + ' ' + sort_direction, "created_at desc") #.paginate(page: params[:page])  in view
    @grand_total = @orders.sum{|o| o[:total]*o.client.fx_rate}

#    flash[:info] = "#{search_results.count} orders found" if keyword
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
    @order = Order.find(params[:id])
  end

  def update
    @order = Order.find(params[:id])
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
    @order =  Order.find(params[:id])
    if @order.status == PENDING_ORDER
      @order.placements.each do |pl|
        pl.ppo.regenerate if pl.ppo.present?
      end 
      @order.destroy
      flash[:success] = "Order deleted"
    else
      flash[:warning] = "Cannot delete Active/Shipped orders."
    end
    redirect_to orders_path
  end

# Cancel Order, update inventory, regenerate PPO. Keep cancelled order in the system.
  def cancel
    @order = Order.find(params[:id])
    @order.placements.each do |pl|
       pl.update_attribute(:status, CANCELLED_ORDER)
       pl.ppo.regenerate if pl.ppo.present?
    end 
    @order.update_attribute(:status, CANCELLED_ORDER) 
    flash[:warning] = 'Order was cancelled. Product quantity adjusted. PPOs regenerated'
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
            @order.regenerate_po
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
        @order.regenerate_invoice
        flash[:info] = 'File regenerated'
        redirect_to download_invoice_order_path(@order)
      end 
    else
      flash[:warning] = 'Order does not exist'
      redirect_to orders_path
    end
  end

# Set all placements to "Shipped"; Regenerate PPO and mark Order as "Shipped"
  def set_to_shipped
    @order = Order.find(params[:id])
    @order.placements.each do |pl|
      pl.set_to_shipped
    end

    flash[:info] = "Order #{@order.id} is set to Shipped"
    redirect_to orders_path #, notice: "Order is set to Shipped"
  end

private

  def order_params
    params.require(:order).permit(:web_id, :status, :po_number, :inv_number, :delivery_by, :terms, :notes, :pmt_method, :shipping, :discount, :tax, :weight, :user_id) 
  end

  def sort_column
    Order.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

end
