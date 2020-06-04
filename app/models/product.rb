class Product < ApplicationRecord

  include ApplicationHelper

  has_many :placements
  has_many :orders, through: :placements
  has_many :ppos
#  has_one  :manager

  default_scope -> { order(ref_code: :asc, release_date: :asc) }

  scope :filter_by_title_or_refcode, lambda { |keyword|
    where("lower(description) LIKE '%#{keyword.downcase}%' OR lower(ref_code) LIKE '%#{keyword.downcase}%'" )
  }

  scope :above_or_equal_to_price, lambda { |price|
    where("price_eu >= ?", price)
  }

  scope :below_or_equal_to_price, lambda { |price|
    where("price_eu <= ?", price)
  }

  scope :recent, -> {
    order(:updated_at)
  }

  validates :ref_code, presence: true, length: { maximum: 10 }, uniqueness: true
  validates :description, :brand, :category, :scale,  presence: true
  validates :price_eu, :price_eu2, :price_usd,  numericality: { greater_than_or_equal_to: 0 }, presence: true
  
  before_validation { description.strip!.gsub!(/\s+/,' ') rescue '' }
  before_validation { ref_code.gsub!(/\W+/,'') rescue '' }
  after_create :send_emails 

# Notify staff, admins
  def send_emails
    UserMailer.new_product(self).deliver 
  end

  def scale_str
    '1:'+scale.to_s
  end

  def brand_str
    BRANDS.invert[self.brand].to_s rescue nil
  end
  
  def progress_str
    self.progress ? "#{self.progress}%":'Unknown' rescue 'Unknown'
  end
  
  def active_str
    self.active? ? 'Yes':'No' rescue 'No'
  end
  
  def manual_price_str
    self.manual_price? ? 'Yes':'No' rescue 'No'
  end
  
  def category_str
    CATEGORIES.invert[self.category].to_s rescue nil
  end

  def colour_str
    COLOURS.invert[self.colour].to_s rescue nil
  end

  def supplier_str
    get_suppliers.invert[self.supplier]
  end

  def manager_str
    get_managers.invert[self.manager]
  end

  def release_date_str
    self.release_date.strftime("%m/%Y") rescue nil
  end
  
  def added_date_str
    self.added_date.strftime("%m/%Y") rescue self.created_at.strftime("%m/%Y")
  end

  def ref_code_and_descr
   "#{ref_code} : #{description}"
  end

  def image_file_present?
    File.exists?(self.image_path)
  end

  def image_path
    IMAGE_BASE.join(self.ref_code+'.jpg') rescue nil 
  end

  def normal_image_rel_path
    return "/images/#{self.ref_code}.jpg" if self.image_file_present?
    return "/images/dummy.jpg" 
  end

  def large_image_rel_path
    return "/images/400/#{self.ref_code}.jpg" if self.image_file_present?
    return "/images/400/dummy.jpg" 
  end
  
  def full_size_image_rel_path
    return "/images/fullsize/#{self.ref_code}.jpg" if self.image_file_present?
    return "/images/fullsize/dummy.jpg" 
  end

# Global method; search by keyword, price below, price above and recently added
  def self.search(keyword = '')
    products = Product.filter_by_title_or_refcode(keyword) if keyword
    products
  end
  
# Return pending orders for the product  
  def pending_order_placements
    self.placements.where(status: PENDING_ORDER)
  end

# Return placements marked as active order 
  def active_order_placements
    self.placements.where(status: ACTIVE_ORDER)
  end

# Return shipped orders for this product  
  def shipped_orders
    self.orders.where(status: SHIPPED_ORDER)
  end

# Return total number of this product in placements with given status
  def total_pcs(status = PENDING_ORDER)  
    self.placements.where(status: status).sum(:quantity) rescue 0
  end

# Last shipped PPO  
  def last_shipped_ppo
    Ppo.where(product_id:self.id).where(status: ARCHIVED_PPO).order('created_at desc').first rescue nil
  end

end
