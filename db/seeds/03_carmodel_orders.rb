# Seed orders table from carmodel csv
#
require_relative '../../config/environment'
require 'csv'

ITEMS_PER_ORDER = 5
$client = Client.find(405)  #! Client Table dependent

puts "About to seed orders table with carmodel orders (from Susanna)"
csv_text = File.read(Rails.root.join('lib', 'seeds', 'carmodel_orders.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1', :col_sep => ',')

def create_order(prod_and_qty)
  user =$client.users.first || User.first
  order = $client.orders.new(user_id: user.id)
  order.build_placements_with_product_ids_and_quantities?(prod_and_qty)
  order.save!
end

# Destroy all orders with dependent Placements
#$client.orders.destroy_all
Order.destroy_all

# Delete all PPOs with associated pdf files 
Ppo.destroy_all # set ppo_id in placements to null before running 
Dir.glob("#{PPOS_PATH}/*.pdf").each { |file| File.delete(file)}

# Reset all inventory to 0:
Product.update_all(quantity: 0)

num =0; prod_and_qty = []
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
      puts "# #{num} Ref code: #{row[0]} => #{new_refcode} qty: #{quantity} : adding to order"
      prod_and_qty.push([prod.id,quantity])
      if prod_and_qty.size > ITEMS_PER_ORDER-1
         create_order(prod_and_qty)
         prod_and_qty = [] 
         puts "*** Next Order" 
      end
    else
      puts "** Product NOT found in DB #{new_refcode}"
    end

  else
    puts "#{row[0]} is not recognized as product code"
  end
end
# Remaining products
create_order(prod_and_qty)

