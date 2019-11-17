class Order < ApplicationRecord

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
      self.total += placement.price * placement.quantity
    end
  end

  def build_placements_with_product_ids_and_quantities?(product_ids_and_quantities)
    product_ids_and_quantities.each do |product_id_and_quantity|
      id, quantity = product_id_and_quantity # [1,5]
      product = Product.find(id)
      case self.client.price_type
        when EU_PRICE 
          product_price = product.price_eu
        when EU2_PRICE
          product_price = product.price_eu2
        when USD_PRICE
          product_price = product.price_usd
        else
          errors.add('*',"Client price_type is invalid")
          return false
      end 

#     self.placements.build(product_id: id, quantity: quantity)
      self.placements.build(product_id: id, quantity: quantity, price: product_price)
    end
  end

  def status_str
    ORDER_STATUSES.invert[self.status] rescue nil
  end

end
