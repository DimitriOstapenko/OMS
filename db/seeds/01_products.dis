#
# Seed products table
#
# Next 3 lines allow to run it in stand-alone
require_relative '../../config/environment'
require 'csv'

puts "About to seed products table. Validity checks for all but :code should be off."
csv_text = File.read(Rails.root.join('lib', 'seeds', 'products.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')

Product.destroy_all

$scale = 0; $cat = ''; $ctns = 0; $name = ''; $type = '';
# first line from jcustomers
  row = csv.first
  row.each do |r|
    s = r.join('').delete("\t\r\n")
    if s.match('^street|racing') 
      ($cat,sc,ct) = s.match(/(\w+)\s+scale\s+(\d+\:\d+)(.+)$/).captures rescue next
       (tmp,$scale) = sc.split(':')
       $scale = $scale.to_i rescue 0
       $ctns = ct.match('.(\d+)').captures.join('').to_i rescue 0
#       puts "cat : #{cat} scale: #{scale} ctns: #{ctns}" 
    else
      if s.length > 3
        $name = s 
        puts "cat : #{$cat}, scale: #{$scale}, ctns: #{$ctns}, name: |#{s}|" 
      end
    end

    if $name && s == $name
      prod = Product.new name: $name, category: $cat, scale: $scale, ctns: $ctns
      if prod.save(validate: false)
          puts "#{prod.id} #{prod.name} saved"
      else
          puts 'Problem code: ', prod.inspect
          puts prod.errors.full_messages
      end
    end
  end

puts " #{Product.count} rows created in products table"

