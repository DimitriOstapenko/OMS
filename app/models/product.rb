class Product < ApplicationRecord

  include ApplicationHelper

  has_many :placements
  has_many :orders, through: :placements

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

  def scale_str
    '1:'+scale.to_s
  end

  def brand_str
    BRANDS.invert[self.brand] rescue nil
  end
  
  def category_str
    CATEGORIES.invert[self.category] rescue nil
  end

  def colour_str
    COLOURS.invert[self.colour] rescue nil
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
    self.added_date.strftime("%m/%Y") rescue nil
  end

  def ref_code_and_descr
   "#{ref_code} : #{description}"
  end

# Global method; search by keyword, price below, price above and recently added
  def self.search(params = {})
    products =  Product.all
    products = products.filter_by_title_or_refcode(params[:findstr]) if params[:findstr]
#    products = products.above_or_equal_to_price(params[:min_price].to_f) if params[:min_price]
#    products = products.below_or_equal_to_price(params[:max_price].to_f) if params[:max_price]
#    products = products.recent(params[:recent]) if params[:recent].present?
    products
  end
  
end
