class PposController < ApplicationController
  
  before_action :logged_in_user
  before_action :admin_or_staff_user, only: [:new, :create, :edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
    @ppos = Ppo.all
    @ppos = @ppos.paginate(page: params[:page])
  end

end
