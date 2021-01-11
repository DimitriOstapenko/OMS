class InventoriesController < ApplicationController
  
   before_action :init, only: [:show, :edit, :update, :download, :destroy ]
#  before_action :logged_in_user
  before_action :production_admin_or_staff_user 
  before_action :admin_or_su_user, only: [:destroy]
  
  helper_method :sort_column, :sort_direction

  def index
    @inventories = Inventory.paginate(page: params[:page])
  end 

  def show
  end

  def new
    @inventory = Inventory.new
  end

  def create
    csv = params[:file][:file] rescue nil
    fn = csv.original_filename if csv
    name = Pathname(fn).basename('.csv').to_s rescue nil
    InventoryCsvUploader.new().store!(csv)

    @inventory = Inventory.new(name: name, csv: csv, user_id: current_user.id )
    if @inventory.save
      flash[:success] = "Inventory processed, file archived"
    else
      flash[:danger] = @inventory.errors.full_messages.to_sentence
    end

    redirect_to inventories_path
  end

  # delete active list, reset placements 'to_ship' attribute.  
  def destroy
    File.delete( @inventory.filespec ) rescue nil
    flash[:success] = "Inventory #{@inventory.name} deleted. "
    @inventory.destroy
    redirect_to inventories_path
  end

  def edit
  end

  def update
    if @inventory.update(inventory_params)
      flash[:success] = "Inventory updated"
      redirect_back(fallback_location: inventories_path)
    else
      render 'edit'
    end
  end

  # download CSV
  def download
    (flash[:warning] = 'Inventory file missing'; redirect_to inventories_path; return) unless @inventory.exists?
    respond_to do |format|
      format.csv {
           send_file(@inventory.csv_path,
           filename: @inventory.filename,
           type: "text/csv",
           disposition: :attachment)
           }
      format.js
    end

    flash.now[:info] = "CSV file downloaded"
  end

private
  def inventory_params
    params.require(:inventory).permit( :name, :description, :lines, :orders, :products, :pcs, :user_id, :status, :md5, :csv )
  end

  def init
    @inventory = Inventory.find(params[:id])
    redirect_to inventories_path unless @inventory
  end

  def sort_column
          Product.column_names.include?(params[:sort]) ? params[:sort] : "ref_code"
  end

  def sort_direction
          %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end


end
