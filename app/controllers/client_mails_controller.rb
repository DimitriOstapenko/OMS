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
  
  def show
    @client_mail = ClientMail.find(params[:id]) rescue nil
    redirect_to client_mails_path unless @client_mail
  end

  def preview_mail
    @client_mail = ClientMail.find(params[:id]) rescue nil
    redirect_to client_mails_path unless @client_mail
  end
  
  def edit
    @client_mail = ClientMail.find(params[:id]) rescue nil
    redirect_to client_mails_path unless @client_mail
  end

  def update
    @client_mail = ClientMail.find(params[:id])
    if @client_mail.update_attributes(client_mail_params)
      flash[:success] = "Email updated"
      redirect_to client_mails_path
    else
      render 'edit'
    end
  end

  def create
    @client_mail = ClientMail.new(client_mail_params)
    if @client_mail.save
      flash[:success] = "New client email was created"
      redirect_to client_mails_path
    else
      render 'new'
    end
  end

  def destroy
    ClientMail.find(params[:id]).destroy
    flash[:success] = "Client mail deleted"
    redirect_to client_mails_path
  end

# Send email to all clients in :client_type category 
  def send_all
    @mail = ClientMail.find(params[:id]) rescue nil
    
    if @mail.present? && @mail.target_emails.present?
      @mail.target_emails_array.each do | destination |
#!!        ClientMailsMailer.send_client_mail(destination,@mail).deliver_later
      end
      client_type_str = CLIENT_TYPES.invert[@mail.client_type] rescue ''
      flash[:success] = "Email with id of #{@mail.id} was sent to #{@mail.target_email_count} clients in  #{client_type_str} category" 
    else
      if @clients.any?
        flash[:warning] = "No emails were sent. Message not found in client_mails table" 
      else
        flash[:warning] = "No emails were sent. Empty target email list"+params.inspect 
      end
    end
    redirect_to client_mails_path
  end

# Send email to staff only (testing) 
  def send_staff
    @mail = ClientMail.find(params[:id]) rescue nil
    
    if @mail.present? 
      @mail.staff_emails_array.each do | destination |
        ClientMailsMailer.send_client_mail(destination,@mail).deliver_now
      end
      flash[:success] = "Email with id of #{@mail.id} was sent to #{@mail.staff_emails_array.count} staff members as a test" 
    end
    redirect_to client_mails_path
  end

  def show_target
    @mail = ClientMail.find(params[:id]) rescue nil
    redirect_to client_mails_path unless @mail
  end

private
  def client_mail_params
    params.require(:client_mail).permit(:title, :ts_sent, :category, :client_type, :body, :target_emails)
  end

  def sort_column
    ClientMail.column_names.include?(params[:sort]) ? params[:sort] : "ts_sent"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end


  
  
end
