# rename files like 'TMR12-04B.jpg' to 'TMR1204B.jpg'

Dir.glob('./*').sort.each do |entry|
  if match = File.basename(entry).match(/(TM\S+)/)
    fname = match[0]
    newEntry = fname.gsub('-', '')
    puts "renaming file #{fname} to #{newEntry}"
    File.rename( entry, newEntry )
  end
end
