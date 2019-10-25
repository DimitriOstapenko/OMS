class ClientsController < ApplicationController

  before_action :logged_in_user
  before_action :admin_or_staff_user #, only: [:index, :edit, :update]
  before_action :admin_user, only: [:destroy]

  def new
    @client = Client.new
  end

  def index
    @clients = Client.paginate(page: params[:page]) #, per_page: 40)
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

  def find
      str = params[:findstr].strip
      flash.now[:info] = "Called find with '#{params[:findstr]}' param"
      @clients = myfind(str)
      if @clients.any?
         flash.now[:info] = "Found #{@clients.count} #{'client'.pluralize(@clients.count)} matching string #{str.inspect}"
      else
         @clients = Client.all
         flash[:danger] = "No clients found"
      end
      @clients = @clients.paginate(page: params[:page])
      render 'index'
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
    params.require(:client).permit( :name, :cltype, :code, :country, :state_prov, :address, :zip_postal, :email, :phone, :contact_person, :web, :notes)
  end

  # Find client by name or scale, depending on input format
  def myfind (str)
        if str.match(/^[[:alpha:]]{,2}$/)
          Client.where("country like ?", "%#{str}%")
        elsif str.match(/^[[:graph:]]+$/)
          Client.where("lower(name) like ?", "%#{str.downcase}%")
        else
          []
        end
  end
end


