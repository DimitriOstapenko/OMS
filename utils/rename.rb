# rename files like 'TOP23A.jpg' to 'TOP023A.jpg'

Dir.glob('./*').sort.each do |entry|
  if match = File.basename(entry).match(/(TOP)(\d+)(\S+)/)
#    puts "'#{match[0]}' : '#{match[1]}' : '#{match[2]}' : '#{match[3]}'"
     
    pref = match[1]
    padded_num = match[2].rjust(3,'0')
    suff = match[3]
    newEntry = pref+padded_num+suff
    puts "renaming file #{match[0]} to #{newEntry}"
    File.rename( entry, newEntry )
  end
end
