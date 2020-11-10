class ReportsController < ApplicationController
  
  include My::Docs
  require 'fileutils'

  before_action :logged_in_user
  before_action :admin_or_staff_user
  before_action :admin_or_staff_user, only: [:destroy]

  helper_method :sort_column, :sort_direction

  def index
    @category = params[:category].to_i || 1
    @reports = Report.where(category: @category)
    @reports = @reports.where(client_id: current_user.client_id) if current_user.client?
    @reports = @reports.reorder(sort_column + ' ' + sort_direction, "created_at desc").paginate(page: params[:page])
    flash.now[:warning] = 'No reports found' unless @reports.any?
  end

  def new
    @report = Report.new(category: params[:category])
  end

  def create
    @report = Report.new(report_params)
    @report.sdate ||= Date.today
    @report.edate ||= Date.today
    year = params[:date][:year] || Date.today.year
    month  = params[:date][:month] || Date.today.month
    
    case @report.timeframe
        when 1   # Day
          @report.edate = @report.sdate + 24.hours rescue Time.now
        when 2   # Week
          @report.edate = @report.sdate + 1.week - 1.minute 
        when 3   # Month
          @report.sdate = Date.new(year.to_i,month.to_i) 
          @report.edate = @report.sdate + 1.month - 1.minute
        when 4   # Quarter to Date
          @report.sdate = Date.today.beginning_of_quarter 
          @report.edate = Time.now 
        when 5   # Year
          @report.sdate = Date.new(year.to_i,1,1) 
          edate = @report.sdate + 1.year
          @report.edate =  [edate, Date.today].min
        when 6   # Date Range
          @report.edate = [report.edate,Date.today].min
        when nil # All Time
          @report.sdate = Order.minimum(:created_at)
          @report.edate = Time.now 
        else     # invalid
          flash.now[:danger] = "Invalid report timeframe: #{@report.timeframe}"
        end

       if flash[:danger]
          redirect_back(fallback_location: reports_path)
       elsif @report.save
          redirect_to export_report_path(@report, category: params[:category] )
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

    redirect_back(fallback_location: reports_path, page: params[:page])
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

# Generate PDF,CSV versions of the report, save in reports directory
  def export
    @report = Report.find(params[:id])
    @orders = get_orders( @report )
    if @orders.any?
      respond_to do |format|
        format.html { @pdf = build_report( @report, @orders )
                      @pdf.render_file @report.filespec
                      redirect_to reports_path(category: @report.category) 
                    }
        format.csv { send_data @orders.to_csv, filename: "#{@report.name}.csv" }
      end
      flash.now[:info] = "New report created. Contains #{@orders.count} orders "
    else
      @report.destroy
      flash[:danger] = "No report created. No orders were found matching given criteria"
      redirect_to reports_path(category: @report.category) 
    end
  end

  def show
    @report = Report.find(params[:id])
    (redirect_to reports_path; return) unless @report

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

# Get orders/placements in given timeframe matching given client/status 
  def get_orders(report)
    case report.category
      when CLIENT_REPORT
      orders = Order.all
      orders = orders.where(client_id: report.client_id) if report.client_id
      orders = orders.where(created_at: (report.sdate..report.edate))
      orders = orders.where(status: report.status) if report.status.present?
      return orders
    when PRODUCT_REPORT
      placements = Placement.where(created_at: (report.sdate..report.edate))
      placements = placements.where(product_id: report.product_id) if report.product_id
      placements = placements.where(status: report.status) if report.status.present?
      placements = placements.joins(:order).where('orders.client_id': report.client_id) if report.client_id
      return placements
    when SUMMARY_REPORT
#p= Placement.joins(:order).where("orders.client_id":405).group(:product_id).pluck(:product_id,'sum(quantity)','sum(shipped)','sum(to_ship)','count(order_id)','sum(price)')
      placements = Placement.where(created_at: (report.sdate..report.edate))
      placements = placements.where(status: report.status) if report.status.present?
      placements = placements.joins(:order).where('orders.client_id': report.client_id) if report.client_id
      return placements
    else 
#      logger.error "*** Invalid Report Category: #{report.inspect}"
#       redirect_to reports_path
       return []
    end
  end

end
