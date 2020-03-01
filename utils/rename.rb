# rename files like 'TOP23A.jpg', 'GP43-A.jpg' to 'TOP023A.jpg','GP043A.jpg'; delete '-'
# Run locally in image dir

num =0
Dir.glob('*.jpg').sort.each do |entry|
  fname = entry.gsub('-','')
  if match = File.basename(fname).match(/(TOP|GP||TM|TMR|TMPD|CAL|GPSET|LS)(\d+)(\S+)/)
#    puts "'#{match[0]}' : '#{match[1]}' : '#{match[2]}' : '#{match[3]}'"
     
    num += 1
    pref = match[1]
    padded_num = match[2].rjust(3,'0')
    suff = match[3]
    newEntry = pref+padded_num+suff
    if entry == newEntry
      puts "#{num}: Kept #{entry}" 
    else 
      puts "#{num}: #{entry} => #{newEntry}"
      File.rename( entry, newEntry )
    end
  else
    puts "**** Ignored #{entry}"
  end

end
