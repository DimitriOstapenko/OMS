class Order < ApplicationRecord

  include ActionView::Helpers::NumberHelper
  belongs_to :client

  validates :client_id, presence: true
  validates_with EnoughProductsValidator

  has_many :placements
  has_many :products, through: :placements

  attr_accessor :quantity # to get quantity from form

  before_validation :set_total!

  def set_total!
    self.total = 0
    placements.each do |placement|
      self.total += placement.product.price_eu * placement.quantity
    end
  end

# Total order amount; localized  
  def total_str (locale=:fr)
    number_to_currency(self.total, locale: locale)
  end

  def build_placements_with_product_ids_and_quantities(product_ids_and_quantities)
    product_ids_and_quantities.each do |product_id_and_quantity|
      id, quantity = product_id_and_quantity # [1,5]

      self.placements.build(product_id: id, quantity: quantity)
    end
  end

end
