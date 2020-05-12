class Order < ApplicationRecord

  require 'csv'
  include My::Docs

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
   
  scope :filter_by_ref_code, lambda { |product_id|  
    joins(:placements).where(placements: {product_id: product_id}) 
  }

  validates :client_id, presence: true
  validates_with EnoughProductsValidator

  has_many :placements, :dependent => :destroy
  has_many :products, through: :placements

  attr_accessor :quantity # to get quantity from form

  before_create :set_attributes!

# *** SET SEND_EMAILS WHEN IN PRODUCTION
  after_create :send_emails! if SEND_EMAILS
  after_save :create_po_and_invoice

# Calculate Order Total including Tax, Discount and Shipping  
  def set_attributes!
    self.total = self.weight = 0
    placements.each do |placement|
      self.total += placement.price * placement.quantity
      self.weight += placement.product.weight/1000 * placement.quantity
    end
    nextid = Order.maximum(:id).next rescue 1
    suff = nextid.to_s
    self.po_number = 'PO-' + suff 
    self.inv_number = 'INV-' + suff
    self.delivery_by = self.client.pref_delivery_by_str
    self.terms = self.client.default_terms
    self.tax = self.total * self.client.tax_pc / 100 if self.client.tax_pc > 0
    self.shipping = self.client.shipping_cost * self.weight 
    self.total += (self.shipping - self.discount + self.tax)
  end

  def send_emails!
    OrderMailer.send_confirmation(self).deliver_now
#    OrderMailer.notify_staff(self).deliver_now
  end

# Total Order price before Taxes, Shipping, Discount etc.  
  def total_price
    self.placements.sum('price*quantity') rescue 0
  end

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

  def pending?
    self.status == PENDING_ORDER 
  end

  def cancelled?
    self.status == CANCELLED_ORDER 
  end

  def shipped?
    self.status == SHIPPED_ORDER 
  end

  def status_str
    ORDER_STATUSES.invert[self.status].to_s rescue nil
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
    attributes = %w{id client_name client_code cre_date product_list product_count total_pcs currency total po_number inv_number pmt_method_str shipping discount tax delivery_by weight status_str notes}
    CSV.generate(headers: attributes, write_headers: true) do |csv|
      all.each do |order|
        csv << attributes.map{ |attr| order.send(attr) }
        if order.placements.count > 1
          order.placements.each do |pl|
            ppo_name = pl.ppo.name rescue ''
            subtotal = pl.price * pl.quantity
            csv << ['', pl.product.ref_code, pl.quantity, pl.price, subtotal, pl.status_str, ppo_name]
          end
        end
      end
    end
  end

  def client_code
    self.client.code rescue nil
  end

  def client_name
    self.client.name rescue nil
  end

  def cre_date
    created_at.to_date
  end

  def product_list
    self.products.pluck(:ref_code).join(':') rescue ''
  end

  def product_count
    self.products.count rescue 0
  end

# Total pieces in all products  
  def total_pcs # items_count
    self.placements.sum(:quantity)
  end

  def po_file_present?
    self.po_filespec.present? && File.exists?(self.po_filespec)
  end
  
  def invoice_file_present?
    self.inv_filespec.present? && File.exists?(self.inv_filespec)
  end

# Are all placement statuses equal to 'status'?
  def all_statuses_are?(status = 0)
    self.placements.all?{|p| p.status == status}
  end

# Are all placements in current order pending?  
  def all_placements_pending?
    self.all_statuses_are?(PENDING_ORDER)
  end
  
# Are all placements in current order marked as active order 
  def all_placements_active?
    self.all_statuses_are?(ACTIVE_ORDER)
  end

# Are all placements in current order marked as shipped
  def all_placements_shipped?
    self.all_statuses_are?(SHIPPED_ORDER)
  end
  
# Are all placements in current order marked as cancelled?
  def all_placements_cancelled?
    self.all_statuses_are?(CANCELLED_ORDER)
  end

# Global search method
  def self.search(keyword = '', client = nil)
    client_id = client.id rescue nil
    orders = Order.joins(:client)
    orders = orders.where(client_id: client_id) if client_id
    case keyword
     when /^\d+/                                     # Order #
       orders = orders.filter_by_order_id(keyword)   
     when /^PO-?\d+/i                                # PO#
       orders = orders.filter_by_po_number(keyword) 
     when /^INV-?\d+/i                               # INVOICE#
       orders = orders.filter_by_invoice_number(keyword) 
     when /^[[:alpha:]]+[[:digit:]]+[[:alpha:]]?$/   # Product Ref Code
        product_id = Product.find_by(ref_code: keyword.upcase).id rescue 0
        orders = orders.filter_by_ref_code(product_id) 
     when /^[[:alpha:]]+$/                           # Client name
       orders = orders.filter_by_client_name(keyword) 
     else
       orders = []
     end

    return orders
  end
  
end
