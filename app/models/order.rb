class Order < ApplicationRecord

  require 'csv'

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
      self.placements.build(product_id: id, quantity: quantity, price: self.client.price(product))
    end
  end

  def status_str
    ORDER_STATUSES.invert[self.status] rescue nil
  end

  def self.to_csv
    attributes = %w{id client_code cre_date total po_number status_str}
    CSV.generate(headers: true) do |csv|
      all.each do |order|
        csv << attributes.map{ |attr| order.send(attr) }
      end
    end
  end

  def client_code
    Client.find(self.client_id).code rescue nil
  end

  def cre_date
    created_at.to_date
  end

end
