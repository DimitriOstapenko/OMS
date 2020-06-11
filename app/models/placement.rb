class Placement < ApplicationRecord

  belongs_to :order, inverse_of: :placements
  belongs_to :product, inverse_of: :placements

  validates :quantity, numericality: { only_integer: true, greater_than: 0 }

  after_create :decrement_product_quantity!

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

# Set placement to shipped; Update PPO if present  
  def set_to_shipped
    self.update_attribute(:status, SHIPPED_ORDER)
    self.order.update_attribute(:status, SHIPPED_ORDER) if self.order.all_placements_shipped?
    if self.ppo.present?
      self.ppo.regenerate 
      self.ppo.update_attribute(:status, ARCHIVED_PPO) if self.ppo.all_placements_shipped?
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



end
