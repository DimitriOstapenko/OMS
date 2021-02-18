class Price < ApplicationRecord
  
  default_scope -> { order(scale: :asc, category: :asc) }

# All prices, except CNY are required:  
  validates :price_eu, :price_eu2, :price_eu3, :price_eu4, :price_eu5, :price_eu6, :price_usd, :price_usd2, presence: true, numericality: true
  validates_uniqueness_of :brand, scope: [:scale, :category], message: ": Rule already present"

  def category_str
    CATEGORIES.invert[self.category] rescue nil
  end
  
  def brand_str
    BRANDS.invert[self.brand] rescue nil
  end
  
  def scale_str
    SCALES.invert[self.scale] rescue nil
  end

end
