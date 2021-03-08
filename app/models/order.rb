class Order < ApplicationRecord

  require 'csv'
  include My::Docs
  include ApplicationHelper
  include ActiveModel::Dirty

  belongs_to :client
  belongs_to :user

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
  validates_with EnoughProductsValidator, on: :create

  has_many :placements, :dependent => :destroy
  has_many :products, through: :placements

  attr_accessor :quantity # to get quantity from form

  before_create :set_attributes!

# set totals and send email to staff on quantity change
  before_update :set_totals!, :send_change_order_emails!

# emails are sent from 'tiny' only when in production mode 
  after_create :send_emails! if SEND_EMAILS
  after_save :changes_applied

# Calculate Order Total including Tax, Discount and Shipping  
  def set_attributes!
    self.total = self.weight = 0.0
    self.geo = self.client.geo
    placements.each do |placement|
       next if placement.cancelled?
       self.total += placement.price * placement.quantity
#       self.weight += placement.product.weight *  placement.quantity rescue 0
    end
    self.weight = placements.sum{|pl| pl.product.weight * pl.quantity} rescue 0
    nextid = Order.maximum(:id).next rescue 1
    suff = nextid.to_s
    self.po_number = 'PO-' + suff 
    self.inv_number = 'INV-' + suff
    self.delivery_by = self.client.pref_delivery_by_str
    self.terms = self.client.default_terms
    self.total += (self.shipping - self.discount + self.tax)
  end

# Chinese order?
  def cn?
    self.geo == GEO_CN
  end

  def world?
    self.geo == GEO_WRLD
  end

  def set_totals!
    self.total = self.total_price + self.shipping - self.discount + self.tax
    self.weight = self.total_weight
  end
  
  def grand_total
    total = read_attribute(:total)
    if total.present?
      return total
    else
      return self.total_price + self.shipping - self.discount + self.tax
    end
  end

  def total
    grand_total
  end

  def cancelled_total
    self.placements.where(status: CANCELLED_ORDER).sum('price*quantity') rescue 0
  end

  def tax
    self.total_price * self.client.tax_pc / 100 rescue 0
  end

  def shipping 
    self.client.shipping_cost * self.weight rescue 0
  end

  def send_emails!
    OrderMailer.notify_staff(self).deliver_now
    OrderMailer.send_confirmation(self).deliver_now
  end

# Send emails to client and staff only if total has changed  
  def send_change_order_emails!
#    logger.debug("******************  changes : #{self.changes} prev: #{self.previous_changes}")
    if self.total_changed? && self.total_was
       self.notes = "#{self.notes} \n Previous total was: #{to_currency(self.total_was, locale: self.client.locale)}"
       OrderMailer.notify_staff_about_changes(self).deliver_now 
#       OrderMailer.send_confirmation_about_changes(self).deliver_now
    end
  end

# Total Order price before Taxes, Shipping, Discount etc.  
  def total_price
    self.placements.where.not(status: CANCELLED_ORDER).sum('price*quantity') rescue 0
  end

# Order total weight  
  def total_weight
    weight = read_attribute(:weight)
    weight ||= self.placements.where.not(status: CANCELLED_ORDER).joins(:product).sum('quantity*weight/1000') rescue 0
    return sprintf("%0.2f", weight)
  end
  
  def weight
    self.total_weight
  end

# Order currency
  def currency
    self.client.currency
  end

  def regenerate_invoice
    pdf = build_invoice(self)
    if pdf 
      File.delete( self.inv_filespec ) rescue nil 
      pdf.render_file self.inv_filespec
    end
  end
            
  def regenerate_po
    pdf = build_po(self)
    if pdf
      File.delete( self.po_filespec ) rescue nil 
      pdf.render_file self.po_filespec
    end
  end
            
# invoice & PO are auto generated, so we just need to delete PDFs on changes to placements
  def delete_pdfs
    File.delete( self.po_filespec ) rescue nil 
    File.delete( self.inv_filespec ) rescue nil 
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
  
  def active?
    self.status == ACTIVE_ORDER 
  end

  def cancelled?
    self.status == CANCELLED_ORDER 
  end

  def shipped?
    self.status == SHIPPED_ORDER 
  end

  def quantity
    self.placements.sum(:quantity)
  end

# Number of cancelled pieces  
  def cancelled
     self.placements.where(status: CANCELLED_ORDER).sum(:quantity)
  end

 # Pending and active 
  def pending(product_id=nil)
    if product_id
      return self.placements.find_by(product_id: product_id).pending rescue 0
    else
      return self.quantity - self.shipped - self.cancelled
    end
  end

  def shipped
    self.placements.sum(:shipped)
  end

  def status_str
    ORDER_STATUSES.invert[self.status].to_s rescue nil
  end

  def paid_str
    self.paid? ? 'Yes' : 'No'
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

  def self.to_csv(detail = TOTAL_ONLY_REPORT)
    itemized = (detail == ITEMIZED_REPORT)
    headres = attributes = %w{id client_code  product_count total_pcs pending shipped cre_date currency po_number inv_number pmt_method_str shipping discount tax total delivery_by status_str notes}
    headers = attributes + %w(Ref Pcs Shipped Price Subtotal Status) if itemized
    CSV.generate(headers: headers, write_headers: true) do |csv|
      all.each do |order|
        csv << attributes.map{ |attr| order.send(attr) }
        if order.placements.any? && itemized
          order.placements.each do |pl|
            ppo_name = pl.ppo.name rescue ''
            subtotal = pl.price * pl.quantity
            csv << ['','','','','','','','','','','','','','','','','','', pl.product.ref_code, pl.quantity, pl.shipped, pl.price, subtotal, pl.status_str, ppo_name]
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

# for CSV not to trigger currency with 'TOP' 
  def product_list_quoted
    self.products.pluck(:ref_code).join(':').inspect rescue ''
  end

  def product_count
    self.products.count rescue 0
  end

# Total pieces in all products  
  def total_pcs # items_count
#    self.placements.sum(:quantity)
    self.placements.where.not(status: CANCELLED_ORDER).sum(:quantity)
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

# Cancel this order, notify admins
  def cancel (by_email)
    self.update_attribute(:status, CANCELLED_ORDER)
    self.update_attribute(:notes, "#{self.notes} \n Cancelled by #{by_email} on #{Time.now}")
    self.placements.each do |placement|
      placement.cancel(by_email)
    end

    OrderMailer.cancelled_order(self,by_email).deliver_now
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

  def made_by 
    self.by_client? ? 'Entered by client' : "Entered by staff #{self.user.email rescue ''}"
  end

  def by_client?
    self.user.email == self.client.contact_email rescue false
  end
end
