class Ppo < ApplicationRecord
        default_scope -> { order(date: :desc) }
        attr_accessor :filename, :filespec
        belongs_to :product #, inverse_of: :products

        before_create :set_attributes!

def set_attributes!
  nextid = Ppo.maximum(:id).next rescue 1
  self.name = "PPO-#{Date.today.strftime("%Y%m%d")}-#{nextid}"
  self.date = Date.today
  self.status = ACTIVE_PPO
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
