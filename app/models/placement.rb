class Placement < ApplicationRecord

  belongs_to :order, inverse_of: :placements
  belongs_to :product, inverse_of: :placements
#  belongs_to :ppo

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

end
