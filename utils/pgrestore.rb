# restore is run on the same day as backup, but later
# use this script on a backup server, run as postgres, or whoever the owner of db is
# 
# N.B! dropdb will fail if db is accessed by other client(s) - stop apache before running! (root cron)
#
#This script is different on debian and OSX. Version below is for OSX

require_relative '../config/environment'
require 'date'

dow = Date.today.wday.to_s
target = '/Users/dmitri/OMS/pgbackup/oms'+dow+'.gz'
puts "This is restore.rb on #{Socket.gethostname} #{Date.today}"

puts "Dropping db 'oms'"
system("/usr/local/bin/dropdb --if-exists oms -e")
puts "Creating db 'oms'"
system("/usr/local/bin/createdb oms")
puts "Restoring DB walkin - full restore from latest backup #{target}"
system("/bin/cat #{target} | /usr/bin/gunzip | /usr/local/bin/psql oms")
puts "done."

