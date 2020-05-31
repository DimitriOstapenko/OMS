class Ppo < ApplicationRecord
        require 'csv'
        include My::Docs

        default_scope -> { order(date: :desc) }
        attr_accessor :filename, :filespec
        belongs_to :product, inverse_of: :ppos
        has_many :placements

        before_create :init
        after_save :set_attributes!

def init
  nextid = Ppo.maximum(:id).next rescue 1
  self.name = "PPO-#{nextid}"
  self.date = Date.today
  self.status = ACTIVE_PPO
  self.orders = self.product.pending_order_placements.count
  self.pcs = self.product.total_pcs
end

def set_attributes!
#  logger.debug "****** pcs: #{self.pcs} orders: #{self.orders}"
  self.product.pending_order_placements.each do |pl|
    pl.update_attributes(ppo_id: self.id, status: ACTIVE_ORDER)
    pl.order.update_attribute(:status, ACTIVE_ORDER) if pl.order.all_placements_active?
  end
end

def status_str
    PPO_STATUSES.invert[self.status].to_s
end

def filename
  self.name+'.pdf'
end

def filespec
  PPOS_PATH.join(self.filename) rescue nil
end

def product_code
  self.product.ref_code
end

def exists?
  File.exists?(self.filespec) rescue false
end

def self.to_csv
  attributes = %w{id name date status_str product_code orders pcs }
    CSV.generate(headers: attributes, write_headers: true) do |csv|
      all.each do |order|
        csv << attributes.map{ |attr| order.send(attr) }
      end
    end
end

# Regenerate PPO after order deleted/cancelled
def regenerate
  pdf = build_ppo_pdf(self)
  File.delete( self.filespec ) rescue nil if pdf
  pdf.render_file self.filespec
end

# Are all placement statuses equal to 'status'?
  def all_statuses_are?(status = 0)
    self.placements.all?{|p| p.status == status}
  end

# Are all placements in current PPO marked as shipped?
  def all_placements_shipped?
    self.all_statuses_are?(SHIPPED_ORDER)
  end

# Are all placements in current PPO marked as cancelled?
  def all_placements_cancelled?
    self.all_statuses_are?(CANCELLED_ORDER)
  end

end
