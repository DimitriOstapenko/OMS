class PposController < ApplicationController
  
  include My::Docs

  before_action :logged_in_user
  before_action :admin_or_staff_user, only: [:new, :create, :edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    @product = Product.find(params[:product_id]) rescue nil
    if @product
      @ppos = @product.ppos.where(status: ACTIVE_PPO)
    else 
      @ppos = Ppo.where(status: ACTIVE_PPO)
    end
    @ppos = @ppos.paginate(page: params[:page])
  end

  def show
    @ppo = Ppo.find(params[:id])
    redirect_to inventories_path unless @ppo

    respond_to do |format|
      format.html {
        send_file(@ppo.filespec,
             filename: @ppo.filename,
             type: "application/pdf",
             disposition: :inline)
      }
      format.js
    end
  end

  def show_placements
    @ppo = Ppo.find(params[:id])
    @placements = @ppo.placements.paginate(page: params[:page])
  end

# Reset active order status back to pending for all product placements 
  def clear_active_order
    @ppo = Ppo.find(params[:id])
    @product = @ppo.product
    @product.active_order_placements.each do |pl|
       pl.update_attribute(:status, PENDING_ORDER)
    end
    flash[:info] = "Active order for #{@product.ref_code} was reset to pending"
    redirect_to inventories_path
  end

# Set Placements across all orders for this product to Back Order, Generate PPO
  def create
    @product = Product.find(params[:product_id])
    @ppo = @product.ppos.create
    pdf = build_ppo_pdf(@ppo) # in My::Docs
    pdf.render_file @ppo.filespec
    flash[:info] = "PPO created for '#{@product.ref_code}'"
    redirect_to inventories_path
  end

# Set active order to shipped
  def set_to_shipped
    @ppo = Ppo.find(params[:id])
    @ppo.placements.each do |pl|
       pl.update_attribute(:status, SHIPPED_ORDER)
       pl.order.update_attribute(:status, SHIPPED_ORDER) if pl.order.all_placements_shipped?
    end
    @ppo.update_attribute(:status, ARCHIVED_PPO)
    flash[:info] = "Order is set to Shipped"
    redirect_to inventories_path
  end

  def download_ppo
    @ppo = Ppo.find(params[:id])

    send_file @ppo.filespec,
      filename: @ppo.filename,
      type: "application/pdf",
      disposition: :attachment

    flash[:info] =  "PPO downloaded"
    redirect_to inventories_path
  end

end
