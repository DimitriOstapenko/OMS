class Placement < ApplicationRecord

  belongs_to :order, inverse_of: :placements
  belongs_to :product, inverse_of: :placements

  after_save :decrement_product_quantity!

  def decrement_product_quantity!
    self.product.decrement!(:quantity, quantity)
  end

  def ptotal
    self.quantity * self.price
  end

end
