class ReportsController < ApplicationController

  before_action :logged_in_user
  before_action :admin_or_staff_user #, only: [:edit, :update]
  before_action :admin_user, only: [:destroy]

  def index
  end

end
