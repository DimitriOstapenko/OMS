# Seed products table
#
# code;scale;description;category;brand;ctns;price_eu
#
# Next 3 lines allow to run it in stand-alone
require_relative '../../config/environment'
require 'csv'

puts "About to seed products table. Validity checks for all but :code should be off."
csv_text = File.read(Rails.root.join('lib', 'seeds', 'products.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1', :col_sep => ';')

Product.destroy_all

  csv.each do |row|
      refcode = row[0].delete("\s\t\r\n")
      prod = Product.new ref_code: refcode, scale: row[1], description: row[2], category: row[3], brand: row[4], ctns: row[5], price_eu: row[6]
      if prod.save(validate: false)
          puts "#{prod.id} #{prod.ref_code} saved"
      else
          puts 'Problem code: ', prod.inspect
          puts prod.errors.full_messages
      end
    end

puts " #{Product.count} rows created in products table"

