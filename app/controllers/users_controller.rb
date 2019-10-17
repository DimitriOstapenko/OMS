class UsersController < ApplicationController

#  before_action :correct_user, only: [:show, :edit, :update]
  before_action :admin_user #, except: [:show, :edit, :update]   #,     only: [:index, :new, :create, :destroy]

  def index
    @users = User.paginate(page: params[:page])
  end


private

#    def user_params
#      params.require(:user).permit(:name, :email, :password, :password_confirmation, :role, :active)
#    end

end
