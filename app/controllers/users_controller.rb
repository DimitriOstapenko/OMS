class UsersController < ApplicationController

  before_action :logged_in_user
  before_action :admin_or_su_user 

  helper_method :sort_column, :sort_direction

  def index
    @users = User.all
    if params[:findstr]
      found = @users.search(params[:findstr])
      if found.any?
        @users = found
        flash.now[:info] = "Found #{@users.count} #{'user'.pluralize(@users.count)} matching string #{params[:findstr].inspect}"
      else
        flash.now[:info] = "No users found"
      end
    end
    @users = @users.reorder(sort_column + ' ' + sort_direction ).paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?  # Leave password blank for no change
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
  
    if @user.update_attributes(user_params)
      msg = "New email will be active once confirmed by the user" if @user.unconfirmed_email.present?
      flash[:success] = "Profile updated. #{msg}"
      redirect_to users_path
#      redirect_to destroy_user_session_path
    else
      render 'edit'
    end
  end
  
  def destroy
    User.find(params[:id]).destroy
    flash[:success] = "User deleted"
    redirect_to users_url
  end

  def switch_to
    if current_user.su?
      sign_in(User.find(params[:id]), scope: :user)
      flash.now[:info] = 'Switched to new user'
    else
      flash.now[:danger] = 'Invalid email/password combination'
    end
    redirect_to root_url
  end


private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :active, :client_id, :invited_by)
    end

    def sort_column
      User.column_names.include?(params[:sort]) ? params[:sort] : "upper(name)"
    end

    def sort_direction
      %w[asc desc].include?(params[:direction]) ? params[:direction] : "asc"
    end

end
