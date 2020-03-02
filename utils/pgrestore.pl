#!/usr/bin/perl
## by Dimitri Ostapenko
## restore is run on the same day as backup, but later of course; 
## use this script on a backup server, run as postgres, or whoever the owner of oms db is
## 
## N.B! dropdb will fail if db is accessed by other client(s) - stop apache before running! (root cron)
## ****  THIS SCRIPT IS IGNORED in global .gitignore as it is platform dependent ****
##
# ARGV : dow (0-sun) optional; use if run from different time zone or just to restore specific day
#

use strict;
my $dow = shift @ARGV;
$dow ||= (localtime)[6];
my $target = '/Users/dmitri/oms/pgbackup/oms'.$dow.'.gz';

print  "This is ", `uname -a`, `date`, " \n";
print "Dropping db 'oms' \n";
# Different path from Debian:
`/usr/local/bin/dropdb --if-exists oms -e`;
print "Creating db 'oms'\n";
# Different path from debian:
`/usr/local/bin/createdb oms`;
print "Restoring DB oms - full restore from backup $target \n";
`/bin/cat  $target | /usr/bin/gunzip | /usr/local/bin/psql oms`;
