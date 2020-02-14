class Order < ApplicationRecord

  require 'csv'
  include My::Forms

  belongs_to :client

  default_scope -> { order(created_at: :desc) }
  
  scope :filter_by_client_name, lambda { |keyword|
    where("upper(clients.name) LIKE '%#{keyword.upcase}%'")
  }

  scope :filter_by_order_id, lambda { |keyword| 
    where("orders.id::varchar like ?", "%#{keyword}%")
  }
  
  scope :filter_by_po_number, lambda { |keyword| 
    where("upper(po_number) LIKE ?", "%#{keyword.upcase}%")
  }
  
  scope :filter_by_invoice_number, lambda { |keyword| 
    where("upper(inv_number) LIKE ?", "%#{keyword.upcase}%")
  }

  validates :client_id, presence: true
  validates_with EnoughProductsValidator

  has_many :placements
  has_many :products, through: :placements

  attr_accessor :quantity # to get quantity from form

  before_create :set_attributes!
  after_create :send_emails!
  after_save :create_po_and_invoice

# Calculate Order Total including Tax, Discount and Shipping  
  def set_attributes!
    self.total = self.weight = 0
    placements.each do |placement|
      self.total += placement.price * placement.quantity
      self.weight += placement.product.weight/1000 * placement.quantity
    end
    nextid = Order.maximum(:id).next rescue 1
    suff = Time.now.strftime("%Y%m%d") + '-' + Order.maximum(:id).nextid.to_s
    self.po_number = 'PO-' + suff 
    self.inv_number = 'INV-' + suff
    self.delivery_by = self.client.pref_delivery_by
    self.terms = self.client.default_terms
    self.tax = self.total * self.client.tax_pc / 100 if self.client.tax_pc > 0
    self.shipping = self.client.shipping_cost * self.weight 
    self.total += (self.shipping - self.discount + self.tax)

  end

  def send_emails!
    OrderMailer.send_confirmation(self).deliver_now
    OrderMailer.notify_staff(self).deliver_now
#    self.update_attributes(delivery_by: self.client.pref_delivery_by, terms: self.client.default_terms )
  end

# Total Order price before Taxes, Shipping, Discount etc.  
  def total_price
    self.placements.sum('price*quantity') rescue 0
  end

 # def currency
 #   if self.client.price_type == USD_PRICE
 #     return 'USD'
 #   else
 #     return 'EURO'
 #   end
 # end

# Order currency
  def currency
    self.client.currency
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
  
  def pmt_method_str
    PAYMENT_METHODS.invert[self.pmt_method].to_s rescue nil
  end

  def po_filespec
    POS_PATH.join(self.po_number+'.pdf') rescue nil
  end
  
  def inv_filespec
    INVOICES_PATH.join(self.inv_number+'.pdf') rescue nil
  end

  def self.to_csv
    attributes = %w{id client_code cre_date product_count items_count currency total po_number inv_number pmt_method_str shipping discount tax delivery_by_str status_str notes}
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

  def product_count
    self.products.count rescue 0
  end

  def items_count
    self.placements.sum(:quantity)
  end

  def po_file_present?
    self.po_filespec.present? && File.exists?(self.po_filespec)
  end
  
  def invoice_file_present?
    self.inv_filespec.present? && File.exists?(self.inv_filespec)
  end

# Global search method
  def self.search(keyword = '')
    orders = Order.joins(:client)
    case keyword
     when /^\d+/
       orders = orders.filter_by_order_id(keyword) 
     when /^PO-?\d+/i
       orders = orders.filter_by_po_number(keyword) 
     when /^INV-?\d+/i
       orders = orders.filter_by_invoice_number(keyword) 
     when /^\w+/
       orders = orders.filter_by_client_name(keyword) 
     else
       orders = []
     end

    return orders
  end
  
end
