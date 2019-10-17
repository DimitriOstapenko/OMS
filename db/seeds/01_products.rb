#
# Seed products table
#
# Next 3 lines allow to run it in stand-alone
require_relative '../../config/environment'
require 'date'
require 'csv'

puts "About to seed products table. Validity checks for all but :code should be off."
csv_text = File.read(Rails.root.join('lib', 'seeds', 'products.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')

#Product.destroy_all

#csv.each do |row|
  row = csv.first
  row.each do |r|
    s = r.join('').delete("\t\r\n")
    puts "|#{s}|" if s.length > 3
  end

#  prod_code = row['prod_code']
#  prod = Product.new   code:  prod_code,
#                         descr: row['prod_desc'],
#                         prob_type: row['prob_type']
#  if diag.save(validate: false)
#          puts "#{prod.id} #{prod.code} saved"
#  else
#          puts 'Problem code: ', prod.inspect
#          puts prod.errors.full_messages
#  end

#end

puts " #{Product.count} rows created in diagnoses table"

