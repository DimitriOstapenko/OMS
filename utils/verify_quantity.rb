# Product.quantity is the sum of all placement quantites. 
# Here we verify that this attribute is set correctly, if not it's adjusted
#

require_relative '../config/environment'

#quantities = Product.joins(:placements).where('placements.status':[0..1]).group('products.id').order('products.ref_code').pluck('products.ref_code, sum(placements.quantity)')

count = 0
Product.all.each do |product|
   target_qty = -product.placements.where(status: [0..1]).sum(:quantity)
   if product.quantity != target_qty 
     puts "#{product.ref_code}: mismatch: target: #{target_qty} current: #{product.quantity} - adjusting"
     product.update_attribute(:quantity, target_qty)
     count += 1
   end
end
 
puts "#{count} product quantities adjusted" 
