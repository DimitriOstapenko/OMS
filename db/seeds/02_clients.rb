#
# Seed clients table
#
# Next 3 lines allow to run it in stand-alone
require_relative '../../config/environment'
require 'csv'

  puts "About to seed clients table. Validity checks for all but :code should be off."
  csv_text = File.read(Rails.root.join('lib', 'seeds', 'clients.csv'))
  csv = CSV.parse(csv_text, :headers => true, :encoding => 'ISO-8859-1')

  Client.destroy_all

  csv.each do |row|
    client = Client.new name: row[0], country: row[1]
    if client.save(validate: false)
            puts "#{client.id} : '#{client.name}' saved"
    else
            puts 'Problem client: ', client.inspect
            puts client.errors.full_messages
    end

  end   
 
  puts " #{Client.count} rows created in clients table"

