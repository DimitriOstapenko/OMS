# Seed clients table
#
# code;scale;description;category;brand;ctns;price_eu
#
# Next 3 lines allow to run it in stand-alone
require_relative '../../config/environment'
require 'csv'

puts "About to seed clients table. Validity checks for all but :code should be off."
csv_text = File.read(Rails.root.join('lib', 'seeds', 'retailers.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1', :col_sep => ',')

Client.destroy_all

# Retailers first (cltype:1), then distributers (cltype: 0)
  csv.each do |row|
    name = row[0].strip rescue nil
    name ||= row['lname']
    name ||= row['fname']
    next unless name

    client = Client.new name: name, 
                        cltype: 1, 
                        country: row[-1], 
                        state_prov: row['state_prov'],
                        address: row['address'],
                        zip_postal: row['zip_postal'],
                        contact_lname: row['lname'],
                        contact_fname: row['fname'],
                        contact_phone: row['phone'],
                        contact_email: row['email'],
                        vat: row['vat']

      if client.save(validate: false)
          puts "#{name}  saved"
      else
          puts 'Problem code: ', client.inspect
          puts client.errors.full_messages
      end
    end

csv_text = File.read(Rails.root.join('lib', 'seeds', 'distributers.csv'))
csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1', :col_sep => ',')

# distributers (cltype: 0)
  csv.each do |row|
    name = row[0].strip rescue nil
    name ||= row['lname']
    name ||= row['fname']
    next unless name

    client = Client.new name: name, 
                        cltype: 0, 
                        country: row[-1], 
                        state_prov: row['state_prov'],
                        address: row['address'],
                        zip_postal: row['zip_postal'],
                        contact_lname: row['lname'],
                        contact_fname: row['fname'],
                        contact_phone: row['phone'],
                        contact_email: row['email'],
                        vat: row['vat']

      if client.save(validate: false)
          puts "#{name}  saved"
      else
          puts 'Problem code: ', client.inspect
          puts client.errors.full_messages
      end
    end

puts " #{Client.count} rows created in clients table"
