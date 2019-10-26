class Product < ApplicationRecord

  require 'action_view'
  include ActionView::Helpers::NumberHelper

   default_scope -> { order(ref_code: :asc, release_date: :asc) }

   validates :ref_code, presence: true, length: { maximum: 10 }, uniqueness: true

  def scale_str
    '1:'+scale.to_s
  end

  def brand_str
    BRANDS.invert[self.brand] rescue nil
  end

  def supplier_str
    SUPPLIERS.invert[self.supplier] rescue nil
  end

  def price_eu_str
    number_to_currency(price_eu, locale: :fr)
  end
  
  def price_eu2_str
    number_to_currency(price_eu2, locale: :fr)
  end

  def price_usd_str
    number_to_currency(price_usd, locale: :us)
  end

  def release_date_str
    self.release_date.strftime("%m/%Y") rescue nil
  end
  
  def added_date_str
    self.added_date.strftime("%m/%Y") rescue nil
  end
end
