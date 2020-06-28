class PackingListsController < ApplicationController

  before_action :logged_in_user
  before_action :production_admin_or_staff_user #, only: [:edit, :update]
#  before_action :admin_or_su_user #, only: [:destroy]

  def index
    @plists = PackingList.all
  end

  def show
    @packing_list = PackingList.find(params[:id])
  end

  def new
  end

  def create
  end

# get - upload form
  def upload
    @packing_list = PackingList.new
    render "upload"
  end

# post - perform upload 
  def upload_csv
    csv = params[:file][:file] rescue nil
    fn = csv.original_filename if csv
    uploader = PlistCsvUploader.new()
    uploader.store!( csv )
    @plist = PackingList.new(name: fn, csv: csv, user_id: current_user.id )
    unless @plist.pcs.positive?
      flash[:danger] = @plist.errors.full_messages.to_sentence
      redirect_to packing_lists_path
      return
    end

    if PackingList.exists?(pcs: @plist.pcs) 
      flash[:danger] = "This packing list was already uploaded - ignored"
    else
      if @plist.save
        flash[:success] = "#{fn}: New packing list saved. Quantities, stock and order statuses updated."
      else 
        flash[:danger] = @plist.errors.full_messages.to_sentence
      end
    end

    redirect_to packing_lists_path
  end

private
  def product_params
    params.require(:'packing_list').permit( :name, :description, :csv, :lines, :orders, :products, :pcs )
  end

end

