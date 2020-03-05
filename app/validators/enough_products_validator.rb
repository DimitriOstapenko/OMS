class EnoughProductsValidator < ActiveModel::Validator
  def validate(record)
    record.placements.each do |placement|
      product = placement.product
      if placement.quantity > product.quantity + LOW_QUANTITY_THRESHOLD
#        record.errors["#{product.ref_code}, #{product.description}"] << "Is out of stock, just #{product.quantity} left"
         qty = product.quantity - placement.quantity
         OrderMailer.product_quantity_alert(product,qty).deliver_later
      end
    end
  end
end
