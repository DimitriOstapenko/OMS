# Set inventory for nown modles; default to 0 for the rest
#
require_relative '../config/environment'
require 'csv'

filename = 'inventory_feb12.csv'
puts "About update inventory for known products from csv file #{filename}" 
csv_text = File.read(Rails.root.join('lib', 'seeds', filename))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1', :col_sep => ',')

count = 0; notfound = [];

  csv.each do |row|
      refcode = row[0].delete("\s\t\r\n")
      quantity = row[1].to_i
      prod = Product.find_by(ref_code: refcode)
      if prod.present?
        count += 1
        prod.quantity = quantity
        if prod.save(validate: false)
           puts "#{count} : ref code: #{refcode} qty set to: #{quantity}"
        else
           puts "error updating product #{refcode} : ", prod.errors.full_messages
        end
      else
        notfound.push(refcode)
        puts "Product '#{refcode}' not found"
      end
    end

puts "Set inventory for #{count} products in products table"
puts "Following products were not found in database : ", notfound.join(',')
