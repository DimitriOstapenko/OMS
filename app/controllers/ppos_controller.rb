class PposController < ApplicationController
  
  before_action :logged_in_user
  before_action :admin_or_staff_user, only: [:new, :create, :edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    @ppos = Ppo.all
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

# Reset back order status for all placements with the product to pending
  def clear_back_order
    @product = Product.find(params[:id])
    @product.back_order_placements.each do |pl|
       pl.update_attribute(:status, PENDING_ORDER)
    end
    flash[:info] = "All items in back order for #{@product.ref_code} were reset to pending"
    redirect_to inventories_path
  end

  def download_ppo
  @product = Product.find(params[:id])

  if @product.ppo_present?
    send_file @product.active_ppo.filespec,
      filename: @product.active_ppo.filename,
      type: "application/pdf",
      disposition: :attachment

    flash[:info] =  "PPO downloaded"
  else
    pdf = build_ppo_pdf(@product)   # in My::Docs
    pdf.render_file @product.active_ppo.filespec
    flash[:info] = 'PPO Regenerated. You can now download it.'
    redirect_to inventories_path
  end
end

end
