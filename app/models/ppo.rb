class Ppo < ApplicationRecord
        default_scope -> { order(date: :desc) }
        attr_accessor :filename, :filespec
        belongs_to :product, inverse_of: :ppos

        before_create :set_attributes!

def set_attributes!
  nextid = Ppo.maximum(:id).next rescue 1
  self.name = "PPO-#{nextid}"
  self.date = Date.today
  self.status = ACTIVE_PPO
  self.orders = self.product.back_order_placements.count
  self.pcs = self.product.back_ordered_pcs
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
