class ReportsController < ApplicationController

  before_action :logged_in_user
  before_action :admin_or_staff_user
  before_action :admin_user, only: [:destroy]

  helper_method :sort_column, :sort_direction

  def index
    @reports = Report.reorder(sort_column + ' ' + sort_direction, "created_at desc").paginate(page: params[:page])
  end

  def new
    @report = Report.new
  end

  def create
    @report = Report.new(report_params)
    if @report.save
       flash[:success] = "New report created"
       redirect_to reports_path
    else
       render 'new'
    end
  end

private
  def report_params
    params.require(:report).permit(:name, :filename, :rtype, :client_id, :sdate, :edate, :timeframe)
  end

  def sort_column
    Report.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end


end
