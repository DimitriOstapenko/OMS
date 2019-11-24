# Full Postgres DB daily backup 

require_relative '../config/environment'
require 'date'

dow = Date.today.wday
target_dir = '/home/oms/backup/'
target_file = "#{target_dir}oms#{dow}.gz"

puts "This is  backup.rb on #{Socket.gethostname} #{Date.today}"

system("/usr/bin/pg_dump --no-acl -d oms -Z5 > #{target_file}")

puts "Finished writing to #{target_file}"
