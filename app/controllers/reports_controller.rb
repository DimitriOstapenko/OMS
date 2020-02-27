class ReportsController < ApplicationController
  
  include My::Docs
  require 'fileutils'

  before_action :logged_in_user
  before_action :admin_or_staff_user
  before_action :admin_user, only: [:destroy]

  helper_method :sort_column, :sort_direction

  def index
    @category = params[:category] || 1
    @reports = Report.where(category: @category)
    @reports = @reports.reorder(sort_column + ' ' + sort_direction, "created_at desc").paginate(page: params[:page])
  end

  def new
    @report = Report.new(category: params[:category])
  end

  def create
    @report = Report.new(report_params)
    year = params[:date][:year]
    month  = params[:date][:month]
    
    case @report.timeframe
        when 1   # Day
                 @report.edate = @report.sdate + 24.hours
        when 2   # Week
                 @report.edate = @report.sdate + 1.week - 1.minute
        when 3   # Month
                 @report.sdate = Date.new(year.to_i,month.to_i)
                 @report.edate = @report.sdate + 1.month - 1.minute
        when 4   # Quarter
                 @report.sdate = Date.today.beginning_of_quarter 
                 @report.edate = Time.now 
        when 5   # Year
                 @report.sdate = Date.new(year.to_i,1,1)
                 @report.edate = @report.sdate + 1.year - 1.minute
        when 6   # Date Range
        when nil # All Time
                 @report.sdate = nil #Date.new(1950,01,01)
                 @report.edate = Time.now 
        else     # invalid
                 flash.now[:danger] = "Invalid report timeframe: #{@report.timeframe}"
        end

       if flash[:danger]
          redirect_back(fallback_location: reports_path)
       elsif @report.save
          redirect_to export_report_path(@report)
       else
          flash.now[:danger] = @report.errors.full_messages.to_sentence
          render 'new'
       end
  end

  def destroy
    @report = Report.find(params[:id])
    if @report.present?
      File.delete( @report.filespec ) rescue nil
      @report.destroy
      flash[:success] = "Report deleted"
    end

    redirect_to reports_url, page: params[:page]
  end

  def download
   @report = Report.find( params[:id] )

   if @report.exists?
          send_file @report.filespec,
             filename: @report.filename,
             type: "application/pdf",
             disposition: :attachment
   else
     flash.now[:danger] = "File #{@report.filename} was not found - regenerating"
     redirect_to export_report_path(@report)
   end
  end

# Generate PDF version of the report, save in reports directory
  def export
    @report = Report.find(params[:id])
    @orders = get_orders( @report )
    if @orders.any?
       @pdf = build_report( @report, @orders )
       @pdf.render_file @report.filespec
       flash[:info] = "New report created. Contains #{@orders.count} orders "
       redirect_to reports_path(category: @report.category) 
    else
      @report.destroy
      flash[:danger] = "No report created. No orders were found matching given criteria"
      redirect_to reports_path(category: @report.category)
    end
  end

  def show
    @report = Report.find(params[:id])
    redirect_to reports_path unless @report

    respond_to do |format|
      format.html {
        send_file(@report.filespec,
             filename: @report.filename,
             type: "application/pdf",
             disposition: :inline)
      }
      format.js
    end
  end

private
  def report_params
    params.require(:report).permit(:name, :filename, :status, :category, :client_id, :product_id, :sdate, :edate, :timeframe, :detail)
  end

  def sort_column
    Report.column_names.include?(params[:sort]) ? params[:sort] : "created_at"
  end

  def sort_direction
    %w[asc desc].include?(params[:direction]) ? params[:direction] : "desc"
  end

# get orders in given timeframe matching given status: Pending and Shipped for Purchases, Paid for Sales
  def get_orders(report)
    sdate = report.sdate || '1900-01-01'.to_date
    orders = Order.where(created_at: (sdate..report.edate))
    if report.category == CLIENT_REPORT 
      orders = orders.where(client_id: report.client_id) if report.client_id
    elsif report.category == PRODUCT_REPORT && report.product_id
      orders = report.product.orders 
    end
    orders = orders.where(status: report.status) 
    return orders
  end

end
