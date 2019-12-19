class Order < ApplicationRecord

  require 'csv'

  belongs_to :client

  default_scope -> { order(created_at: :desc) }

  validates :client_id, presence: true
  validates_with EnoughProductsValidator

  has_many :placements
  has_many :products, through: :placements

  attr_accessor :quantity # to get quantity from form

  before_validation :set_attributes!

  def set_attributes!
    self.total = 0
    placements.each do |placement|
      self.total += placement.price * placement.quantity
    end
    suff = Time.now.strftime("%Y%m%d") + '-' +Order.maximum(:id).next.to_s
    self.po_number = 'PO' + suff 
    self.inv_number = 'INV' + suff
  end
  
  def build_placements_with_product_ids_and_quantities?(product_ids_and_quantities)
    return false unless product_ids_and_quantities.any?
    product_ids_and_quantities.each do |product_id_and_quantity|
      id, quantity = product_id_and_quantity # [1,5]
      product = Product.find(id) rescue nil
      next unless product.present? 
      self.placements.build(product_id: id, quantity: quantity, price: self.client.price(product))
    end
  end

  def status_str
    ORDER_STATUSES.invert[self.status] rescue nil
  end

  def po_filespec
    POS_PATH.join(self.po_number) rescue nil
  end

  def self.to_csv
    attributes = %w{id client_code cre_date product_count currency total po_number status_str}
    CSV.generate(headers: attributes, write_headers: true) do |csv|
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

  def currency
    if self.client.price_type == USD_PRICE
      return 'USD'
    else
      return 'EURO'
    end
  end

  def product_count
    self.products.count rescue 0
  end

  def po_file_present?
    File.exists?(self.po_filespec)
  end
  
end
