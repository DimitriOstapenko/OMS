class EnoughProductsValidator < ActiveModel::Validator
  def validate(record)
    record.placements.each do |placement|
      product = placement.product
      if placement.quantity > LOW_QUANTITY_THRESHOLD - product.quantity 
#        record.errors["#{product.ref_code}, #{product.description}"] << "Is out of stock"
#         qty = product.quantity - placement.quantity
         OrderMailer.product_quantity_alert(product).deliver_later
      end
    end
  end
end
