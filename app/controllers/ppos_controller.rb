class PposController < ApplicationController
  
  include My::Docs

  before_action :logged_in_user
  before_action :admin_or_staff_user, only: [:new, :create, :edit, :update]
  before_action :admin_or_su_user, only: [:destroy]

  def index
    @product = Product.find(params[:product_id]) rescue nil
    if @product
      @ppos = @product.ppos.where(status: ACTIVE_PPO)
    else 
      @ppos = Ppo.all
    end
    @ppos = @ppos.paginate(page: params[:page])
  end

  def show
    @ppo = Ppo.find(params[:id]) rescue nil
    @product = @ppo.product rescue nil
    redirect_to inventories_path unless @ppo

    respond_to do |format|
      format.html {
        begin
        send_file @ppo.filespec,
             filename: @ppo.filename,
             type: "application/pdf",
             disposition: :inline
        rescue Exception => e
          flash[:warning] = "PPO file missing - regenerating" 
          pdf = build_ppo_pdf(@ppo)
          pdf.render_file @ppo.filespec if @ppo
          redirect_to product_ppo_path(@product,@ppo)
        end
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
    redirect_back(fallback_location: inventories_path)
  end

# Set orders in this PPO to Active; Generate PPO pdf
  def create
    @product = Product.find(params[:product_id])
    @ppo = @product.ppos.create
    pdf = build_ppo_pdf(@ppo) # in My::Docs
    pdf.render_file @ppo.filespec
    flash[:info] = "PPO created for '#{@product.ref_code}'"
    redirect_back(fallback_location: inventories_path)
  end
  
  def destroy
    @ppo = Ppo.find(params[:id])
    if @ppo.present?
      File.delete( @ppo.filespec ) rescue nil
      @ppo.destroy
      flash[:success] = "PPO deleted"
    end
    redirect_to ppos_url
  end

# Set PPO to shipped
  def set_to_shipped
    @ppo = Ppo.find(params[:id]); msg = '';
    @ppo.placements.each do |pl|
      pl.set_to_shipped
      msg << "; Order #{pl.order_id} is set to Shipped " if pl.order.all_placements_shipped?
    end
    flash[:info] = "PPO #{@ppo.id} is set to Shipped #{msg}"
    redirect_to inventories_path
  end

  def download
    @ppo = Ppo.find(params[:id])
    @product = @ppo.product
    begin
    send_file @ppo.filespec,
      filename: @ppo.filename,
      type: "application/pdf",
      disposition: :attachment
    rescue Exception => e
      flash[:warning] = "PPO file missing - regenerating"
      pdf = build_ppo_pdf(@ppo) if @ppo
      pdf.render_file @ppo.filespec
      redirect_to inventories_path
    end
  end

  def export
    @ppos = Ppo.all
    send_data @ppos.to_csv, filename: "PPOs-#{Date.today}.csv"
#    flash.now[:info] = 'All PPOs exported to CSV file'
  end

end
