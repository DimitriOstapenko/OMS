class ClientsController < ApplicationController

  before_action :init, only: [:show, :edit, :update, :destroy, :send_invite_to_register ]
  before_action :logged_in_user
  before_action :production_admin_or_staff_user #, only: [:index, :edit, :update]
  before_action :admin_or_su_user, only: [:destroy]
  before_action :verify_client_geo, only: [:show, :edit, :update]

  helper_method :sort_column, :sort_direction

  def new
    @client = Client.new
  end

  def index
    @clients = Client.all; found = []
    @clients = @clients.where(geo: GEO_CN) if current_user.production?
    found = @clients.search(params[:findstr]) if params[:findstr]
    if found.any?
      @clients = found
      flash.now[:info] = "Found #{@clients.count} #{'client'.pluralize(@clients.count)} matching string #{params[:findstr].inspect}"
    else 
      flash.now[:warning] = 'Nothing found' if params[:findstr]
    end
    @clients = @clients.reorder(sort_column + ' ' + sort_direction ).paginate(page: params[:page])  
  end

  def show
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
    @client.destroy
    flash[:success] = "Client deleted"
    redirect_back(fallback_location: clients_path)
  end

   def edit
  end

  def update
    if @client.update(client_params)
      flash[:success] = "Client updated"
      redirect_to clients_path
    else
      render 'edit'
    end
  end
  
# This is invite to change password only. Registration is automatic
  def send_invite_to_register
    if @client.present?
      @user = User.find_by(email: @client.contact_email) 
      if @user
        msg =  "Client '#{@client.name}' was just invited to complete registration"
        ClientMailer.send_invite_to_register(@client,@user).deliver_now
      else
        @user = User.new(name: @client.name, email: @client.contact_email, role: :client, invited_by: current_user.name, password: Time.now)
        if @user.save
          ClientMailer.send_invite_to_register(@client,@user).deliver_now
          msg =  "New user created. Client '#{@client.name}' was just invited to complete registration"
        else   
          msg = "Client was not invited. Errors saving user: #{@user.errors.full_messages.join}"
        end
      end
    else 
      msg = "Client was not found"
    end

    flash[:info] = msg
    redirect_to clients_path
#    redirect_back(fallback_location: clients_path)
  end

private
  def client_params
    params.require(:client).permit( :name, :cltype, :code, :country, :state_prov, :address, :zip_postal, :web, :notes, 
                                    :contact_fname, :contact_lname, :vat, :contact_phone, :contact_email, :price_type, 
                                    :pref_delivery_by, :default_terms, :tax_pc, :shipping_cost, :geo )
  end
  
  def init
    @client = Client.find(params[:id]) rescue nil
    (flash[:warning] = "Client not found"; redirect_to clients_path) unless @client
  end

  def sort_column
    Client.column_names.include?(params[:sort]) ? params[:sort] : "upper(name)"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
  end

end


