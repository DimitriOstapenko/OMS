# Seed orders table from carmodel csv
#
require_relative '../../config/environment'
require 'csv'

puts "About to seed orders table with carmodel orders (from Susanna)"
csv_text = File.read(Rails.root.join('lib', 'seeds', 'carmodel_orders.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1', :col_sep => ',')

Order.destroy_all
client = Client.find(405)  #! Client Table dependent

num =0
csv.each do |row|
    refcode = row[0].strip rescue nil
    quantity = row[1].to_i rescue nil

# skip empties
    next unless refcode && quantity.positive?

# Clean up and pad refcode to be consistent with ours    
  refcode.gsub!('-','')

  if match = refcode.match(/(TOP|TOPSET|GP|TM|TMR|TMPD|CAL|GPSET|LS)(\d+)(\S+)?/)
#    puts "**** '#{match[0]}' : '#{match[1]}' : '#{match[2]}' : '#{match[3]}'"
     
    num += 1
    pref = match[1]
    padded_num = match[2].rjust(3,'0')
    suff = match[3]
    new_refcode = "#{pref}#{padded_num}#{suff}"
    
    prod = Product.find_by(ref_code: new_refcode)
    if prod
      puts "# #{num} Ref code: #{row[0]} => #{new_refcode} qty: #{quantity} : creating order"
      order = client.orders.new()
      prod_and_qty = [[prod.id,quantity]]
      order.build_placements_with_product_ids_and_quantities?(prod_and_qty)
      order.save!
    else
      puts "** Product NOT found in DB #{new_refcode}"
    end

  else
    puts "#{row[0]} is not recognized as product code"
  end
end
