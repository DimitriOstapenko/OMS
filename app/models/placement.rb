class Placement < ApplicationRecord
  
  require 'csv'

  belongs_to :order, inverse_of: :placements
  belongs_to :product, inverse_of: :placements

  validates :quantity, numericality: { only_integer: true}

#  after_create :decrement_product_quantity!
  default_scope -> {order(product_id: :asc) }

  def ptotal
    return 0 if self.cancelled?
    self.quantity * self.price
  end

  def status_str
    ORDER_STATUSES.invert[self.status].to_s
  end

  def ppo
    Ppo.find(ppo_id) rescue nil
  end

  def client_name
    self.order.client_name
  end

  def client_code
    self.order.client_name
  end

  def po_number
    self.order.po_number
  end

  def inv_number
    self.order.inv_number
  end

  def ordered
    self.created_at.to_date
  end  

# Set placement to shipped; set shipped quantity, order status; Update PPO if present  
  def set_to_shipped
    self.update_attribute(:status, SHIPPED_ORDER)
#    logger.debug("****** #{self.product.quantity} : #{self.quantity} : #{self.shipped}")
    self.update_attribute(:shipped, self.quantity)
    self.order.update_attribute(:status, SHIPPED_ORDER) if self.order.all_placements_shipped?
    self.update_attribute(:to_ship, 0)
    if self.ppo.present?
      self.ppo.regenerate 
      self.ppo.update_attribute(:status, ARCHIVED_PPO) if self.ppo.all_placements_shipped?
    end
  end

  def set_to_active
    self.update_attribute(:status, ACTIVE_ORDER)
  end

# Ship placement in Packing List  
  def ship_plist
    if self.to_ship < self.quantity
      self.update_attribute(:shipped, self.to_ship)
      self.order.update_attribute(:status, ACTIVE_ORDER)
      self.ppo.delete_pdf if self.ppo.present?
      self.update_attribute(:to_ship, 0)
    else
      self.set_to_shipped
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

  # Pending and active
  def pending
    return 0 if self.cancelled?
    self.quantity - self.shipped 
  end

  def ref_code
    self.product.ref_code.inspect
  end

  def delete_pdfs
    self.ppo.delete_pdf if self.ppo.present?
    self.order.delete_pdfs # invoice + PO
  end

# Cancel this placement, cancel order if all placements canceled 
  def cancel(by_email)
    return unless self.pending?
    self.update_attributes(status: CANCELLED_ORDER)
    self.delete_pdfs
    self.order.save
    return if self.order.cancelled?
    self.order.cancel(by_email) if self.order.all_placements_cancelled?
  end

  def self.to_csv(detail = TOTALS_ONLY_REPORT)
    cn_client  = all.first.order.client.cn? rescue false
    if cn_client
      attributes = %w{ref_code client_code order_id quantity pending shipped to_ship ordered status_str po_number inv_number ppo_id packing_list_id status_str}
    else
      attributes = %w{ref_code client_code order_id quantity pending shipped to_ship ordered status_str price ptotal po_number inv_number ppo_id packing_list_id status_str}
    end
    CSV.generate(headers: attributes, write_headers: true) do |csv|
      all.each do |placement|
        csv << attributes.map{ |attr| placement.send(attr) }
      end
    end
  end

end
