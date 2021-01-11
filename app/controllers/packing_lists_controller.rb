class PackingListsController < ApplicationController

  before_action :init, only: [:show, :edit, :update, :download, :destroy, :ship ]
  before_action :logged_in_user
  before_action :production_admin_or_staff_user #, only: [:edit, :create, :update ]
  before_action :admin_or_su_user, only: [:destroy]

  def index
    @plists = PackingList.all
  end

  def show
  end

  def new
    @packing_list = PackingList.new
  end

  def create
    csv = params[:file][:file] rescue nil
    fn = csv.original_filename if csv
    name = Pathname(fn).basename('.csv').to_s rescue nil
    PlistCsvUploader.new().store!(csv)

    @plist = PackingList.new(name: name, csv: csv, user_id: current_user.id )
    if @plist.save
      flash[:success] = "New packing list created. 'To ship' quantities updated"
    else
      flash[:danger] = @plist.errors.full_messages.to_sentence
    end

    redirect_to packing_lists_path
  end

  # delete active list, reset placements 'to_ship' attribute.  
  def destroy
    @packing_list.placements.each do |pl|
      pl.update(to_ship: 0, packing_list_id: nil)
    end
    File.delete( @packing_list.filespec ) rescue nil
    flash[:success] = "Packing list #{@packing_list.name} deleted. "
    @packing_list.destroy
    redirect_to packing_lists_path
  end

  def edit
  end

  def update
    if @packing_list.update(packing_list_params)
      flash[:success] = "Packing List updated"
      redirect_back(fallback_location: packing_lists_path)
    else
      render 'edit'
    end
  end

# Ship this packing list: change quantities and statuses  
  def ship
    @packing_list.placements.each do |pl|
      pl.ship_plist
    end
    @packing_list.update_attribute(:status, ARCHIVED_PLIST)
    flash[:success] = "Packing List shipped"
    redirect_to packing_lists_path 
  end

# download CSV  
  def download
    (flash[:warning] = 'Packing list file missing'; redirect_to packing_lists_path; return) unless @packing_list.exists?
    respond_to do |format|
      format.csv { 
           send_file(@packing_list.csv_path,
           filename: @packing_list.filename,
           type: "text/csv",
           disposition: :attachment)    
           }
      format.js
    end

    flash.now[:info] = "CSV file downloaded"
  end

private
  def init
    @packing_list = PackingList.find(params[:id]) rescue nil
    (flash[:warning]="Packing List not found"; redirect_to packing_lists_path) unless @packing_list 
  end

  def packing_list_params
    params.require(:'packing_list').permit( :name, :description, :csv, :lines, :orders, :products, :pcs, :status, :md5 )
  end

end

