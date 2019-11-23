# go throug images and add missing ones along with ref_code to products table 

require_relative '../config/environment'
require 'pathname'

dir = IMAGE_BASE
count = 0

Pathname.glob("#{dir}/[TLG]*.jpg").sort.each do |entry|
  (refcode,ext) = entry.basename.to_s.split('.')
  next if Product.exists?(ref_code: refcode)

  case refcode
  when /^T/
    brand = BRANDS[:'Top Marques']
  when /^G/
    brand = BRANDS[:'GP Replicas']
  when /^L/
    brand = BRANDS[:'LS Collectibles']
  else
    brand = nil
  end
  
  product = Product.new ref_code: refcode,
                  description: '',
                  brand: brand,
                  category: 'racing', 
                  scale: 18,
                  added_date: Date.today,
                  price_eu: 0,
                  price_eu2: 0,
                  price_usd: 0,
                  ctns: 4

  if product.save(validate: false)
          puts "New product #{refcode} saved"
      else
          puts 'Problem saving product: ', product.inspect
          puts product.errors.full_messages
      end

  count += 1
end

puts "#{count} new products added"

