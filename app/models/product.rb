class Product < ApplicationRecord

  require 'action_view'
  include ActionView::Helpers::NumberHelper
  
  has_many :placements
  has_many :orders, through: :placements

#  belongs_to :client  # Does not let admin to edit

  default_scope -> { order(ref_code: :asc, release_date: :asc) }

  scope :filter_by_title, lambda { |keyword|
    where("lower(description) LIKE ?", "%#{keyword.downcase}%" )
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
  validates :description, :brand, :category, presence: true
  validates :price_eu, numericality: { greater_than_or_equal_to: 0 }, presence: true

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

  def self.search(params = {})
    products = params[:product_ids].present? ? Product.where(id: params[:product_ids]) : Product.all

    products = products.filter_by_title(params[:keyword]) if params[:keyword]
    products = products.above_or_equal_to_price(params[:min_price].to_f) if params[:min_price]
    products = products.below_or_equal_to_price(params[:max_price].to_f) if params[:max_price]
    products = products.recent(params[:recent]) if params[:recent].present?

    products
  end
end
