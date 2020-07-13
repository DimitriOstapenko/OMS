#!/home/oms/.rvm/rubies/ruby-2.6.4/bin/ruby
# restore is run on the same day as backup, but later
# use this script on a backup server, run as postgres, or whoever the owner of db is
# 
# N.B! dropdb will fail if db is accessed by other client(s) - stop apache before running! (root cron)
#
#This script is different on debian and OSX. Version below is for debian

require_relative '../config/environment'
require 'date'

dow = Date.today.wday.to_s
target = '/home/oms/backup/oms'+dow+'.gz'
puts "This is restore.rb on #{Socket.gethostname} #{Date.today}"

puts "Dropping db 'oms'"
system("/usr/bin/dropdb --if-exists oms -e")
puts "Creating db 'oms'"
system("/usr/bin/createdb oms")
puts "Restoring DB oms - full restore from latest backup #{target}"
system("/bin/cat #{target} | /bin/gunzip | /usr/bin/psql oms")
puts "done."

