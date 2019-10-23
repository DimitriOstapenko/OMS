class Product < ApplicationRecord

  require 'action_view'
  include ActionView::Helpers::NumberHelper

   default_scope -> { order(name: :asc, release_date: :asc) }


  def scale_str
    '1:'+scale.to_s
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
end
