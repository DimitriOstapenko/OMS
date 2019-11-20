class ClientsController < ApplicationController

  before_action :logged_in_user
  before_action :admin_or_staff_user #, only: [:index, :edit, :update]
  before_action :admin_user, only: [:destroy]

  helper_method :sort_column, :sort_direction

  def new
    @client = Client.new
  end

  def index
    if params[:findstr]
      @clients = Client.search(params).paginate(page: params[:page])
      if @clients.any?
        flash.now[:info] = "Found #{@clients.count} #{'client'.pluralize(@clients.count)} matching string #{params[:findstr].inspect}"
      else
        flash.now[:info] = "No clients found matching string #{params[:findstr].inspect}"
      end
    else
      @clients = Client.reorder(sort_column + ' ' + sort_direction, "name asc").paginate(page: params[:page]) 
    end
  end

  def show
    @client = Client.find(params[:id])
  end

  def create
    @client = Client.new(client_params)
    if @client.save
       flash[:success] = "New client created"
       redirect_to clients_path
    else
       render 'new'
    end
  end

  def destroy
    Client.find(params[:id]).destroy
    flash[:success] = "Client deleted"
    redirect_to clients_path
  end

   def edit
    @client = Client.find(params[:id])
  end

  def update
    @client = Client.find(params[:id])
    if @client.update_attributes(client_params)
      flash[:success] = "Client updated"
      redirect_to clients_path
    else
      render 'edit'
    end
  end

private
  def client_params
    params.require(:client).permit( :name, :cltype, :code, :country, :state_prov, :address, :zip_postal, :web, :notes, 
                                    :contact_fname, :contact_lname, :vat, :contact_phone, :contact_email, :price_type)
  end

  def sort_column
    Client.column_names.include?(params[:sort]) ? params[:sort] : "name"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end


