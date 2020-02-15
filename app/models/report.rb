class Report < ApplicationRecord
        default_scope -> { order(id: :desc) }
        attr_accessor :client, :filespec
#  belongs_to :client, inverse_of: :reports
  
        before_validation :set_attributes!

        validates :name, :filename, presence: true, length: { maximum: 30 }
        validates :timeframe, :client_id, :detail,  numericality: { only_integer: true }, allow_blank: true
        validates :sdate, presence: true, if: Proc.new { |a| a.rtype == DAY_REPORT || a.rtype == DRANGE_REPORT}
        validates :edate, presence: true, if: Proc.new { |a| a.rtype == DRANGE_REPORT}

  def set_attributes!
    self.rtype = 'ALL' unless self.rtype?
    sdate = self.sdate.to_date rescue nil
    nextid = Report.maximum(:id).next rescue 1
    self.name = "#{self.rtype}-#{Date.today}-#{nextid}"
    self.filename = self.name+'.pdf'
    old_report = Report.find_by(filename: self.filename)
    if old_report.present?
       File.delete( old_report.filespec ) rescue nil
       old_report.destroy
    end
  end 

  def client
    Client.find(self.client_id) rescue nil
  end
  
  def client_code
    self.client.code rescue 'All'
  end

  def filespec
    REPORTS_PATH.join(filename) rescue nil
  end

  def exists?
    File.exists?(self.filespec) rescue false
  end

  def filesize
    sprintf("%.2f", File.size(self.filespec).to_f/2**20) rescue 0
  end

  def rtype_str
    REPORT_TYPES.invert[self.rtype] || 'Sales And Purchases'
  end

  def category_str
    REPORT_CATEGORIES.invert[self.category] || 1
  end
  
  def timeframe_str
    REPORT_TIMEFRAMES.invert[self.timeframe] || 'All Time'
  end

  def detail_str
    REPORT_DETAILS.invert[self.detail]
  end

  def daterange 
    return '' unless self.sdate
    if self.timeframe == DAY_REPORT 
      return self.sdate.to_date
    else
      return "#{self.sdate.to_date} - #{self.edate.to_date}" 
    end
  end

end
