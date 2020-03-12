class Ppo < ApplicationRecord
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
  logger.debug "****** pcs: #{self.pcs} orders: #{self.orders}"
  self.product.pending_order_placements.each do |pl|
    pl.update_attributes(ppo_id: self.id, status: ACTIVE_ORDER)
    pl.order.update_attribute(:status, ACTIVE_ORDER) if pl.order.all_placements_on_backorder?
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

def exists?
  File.exists?(self.filespec) rescue false
end

end
