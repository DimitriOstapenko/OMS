class ClientMailsController < ApplicationController

  before_action :logged_in_user
  before_action :admin_or_staff_user 
  before_action :admin_user, only: [:destroy]

  helper_method :sort_column, :sort_direction

  def index
    @client_mails = ClientMail.reorder(sort_column + ' ' + sort_direction, "ts_sent desc").paginate(page: params[:page])
  end

  def new
    @client_mail = ClientMail.new
  end

  def create
    @client_mail = ClientMail.new(client_mail_params)
    if @client_mail.save
       flash[:success] = "New client email created"
       redirect_to client_mails_path
    else
       render 'new'
    end
  end

private
  def client_mail_params
    params.require(:client_mail).permit(:title, :ts_sent, :category, :client_type, :body)
  end

  def sort_column
    ClientMail.column_names.include?(params[:sort]) ? params[:sort] : "ts_sent"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end


  
  
end
