class UsersController < ApplicationController

  before_action :admin_user 

  def index
    @users = User.paginate(page: params[:page])
  end

  def show
    @user = User.find(params[:id])
  end

  def edit
    @user = User.find(params[:id])
  end

  def update
    @user = User.find(params[:id])
    if params[:user][:password].blank? && params[:user][:password_confirmation].blank?
      params[:user].delete(:password)
      params[:user].delete(:password_confirmation)
    end
  
    if @user.update_attributes(user_params)
      @user.update_attribute(:client_id, nil) unless @user.role == 'client'
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
    if current_user.admin?
      sign_in(User.find(params[:id]), scope: :user)
      flash.now[:info] = 'Switched to new user'
    else
      flash.now[:danger] = 'Invalid email/password combination'
    end
    redirect_to root_url
  end


private

    def user_params
      params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :active, :client_id)
    end

end
