class Placement < ApplicationRecord
  
  require 'csv'

  belongs_to :order, inverse_of: :placements
  belongs_to :product, inverse_of: :placements

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  after_create :decrement_product_quantity!
  default_scope -> {order(product_id: :asc) }

  def decrement_product_quantity!
    self.product.decrement!(:quantity, quantity)
  end

  def ptotal
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

# Set placement to shipped; update product quantity(pcs in active/pending orders); Update PPO if present  
  def set_to_shipped
    self.update_attribute(:status, SHIPPED_ORDER)
    if self.shipped < self.quantity
      self.product.update_attribute(:quantity, self.product.quantity + self.quantity - self.shipped)
      self.update_attribute(:shipped, self.quantity)
      self.update_attribute(:to_ship, 0)
    end 
    self.order.update_attribute(:status, SHIPPED_ORDER) if self.order.all_placements_shipped?
    if self.ppo.present?
      self.ppo.regenerate 
      self.ppo.update_attribute(:status, ARCHIVED_PPO) if self.ppo.all_placements_shipped?
    end
  end

# Ship placement in Packing List  
  def ship_plist
    if self.quantity == self.to_ship
      self.set_to_shipped
    else
      self.update_attribute(:quantity, self.quantity - self.to_ship)
      self.update_attribute(:to_ship, 0)
      self.order.update_attribute(:status, ACTIVE_ORDER)
      self.ppo.regenerate if self.ppo.present?
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
    self.quantity - self.shipped
  end

  def ref_code
    self.product.ref_code.inspect
  end

  def self.to_csv
    attributes = %w{order_id client_name ref_code created_at quantity price ptotal ppo_id shipped pending to_ship packing_list_id status_str}
    CSV.generate(headers: attributes, write_headers: true) do |csv|
      all.each do |placement|
        csv << attributes.map{ |attr| placement.send(attr) }
      end
    end
  end

end
