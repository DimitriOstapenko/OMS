class Order < ApplicationRecord

  require 'csv'
  include My::Forms

  belongs_to :client

  default_scope -> { order(created_at: :desc) }

  validates :client_id, presence: true
  validates_with EnoughProductsValidator

  has_many :placements
  has_many :products, through: :placements

  attr_accessor :quantity # to get quantity from form

  before_validation :set_attributes!
  after_create :send_emails!
  after_save :create_po_and_invoice

  def set_attributes!
    self.total = 0
    placements.each do |placement|
      self.total += placement.price * placement.quantity
    end
    unless self.po_number.present?
      suff = Time.now.strftime("%Y%m%d") + '-' + Order.maximum(:id).next.to_s
      self.po_number = 'PO-' + suff 
      self.inv_number = 'INV-' + suff
    end
  end

  def send_emails!
    OrderMailer.send_confirmation(self).deliver_now
    OrderMailer.notify_staff(self).deliver_now
    self.update_attributes(delivery_by: self.client.pref_delivery_by, terms: self.client.default_terms )
  end

  def create_po_and_invoice 
      pdf = build_po(self)
      pdf.render_file self.po_filespec rescue nil
      pdf = build_invoice(self)
      pdf.render_file self.inv_filespec rescue nil
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
    ORDER_STATUSES.invert[self.status].to_s rescue nil
  end

  def delivery_by_str
    DELIVERY_BY.invert[self.delivery_by].to_s rescue nil
  end

  def terms_str
    PAYMENT_TERMS.invert[self.terms].to_s rescue nil
  end

  def po_filespec
    POS_PATH.join(self.po_number+'.pdf') rescue nil
  end
  
  def inv_filespec
    INVOICES_PATH.join(self.inv_number+'.pdf') rescue nil
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
    self.po_filespec.present? && File.exists?(self.po_filespec)
  end
  
  def invoice_file_present?
    self.inv_filespec.present? && File.exists?(self.inv_filespec)
  end
  
end
