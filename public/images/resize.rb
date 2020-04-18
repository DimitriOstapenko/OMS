# resize images in current directory and put them into subdirectory [width]
# ARG: width (px, preserve ratio)
#
require 'pathname'

width = ARGV[0] || '250'
abort "Usage: ruby resize.rb %width" unless (width && width.to_f > 0)  # 0 if not a number

curdir = Pathname.new(Dir.pwd)
target = curdir.join(width)

Dir.mkdir(target) unless File.exists?(target)
puts "** Target dir: #{target} width: #{width}%"

Pathname.glob("#{curdir}/*.jpg").sort.each do |entry|
  basename = entry.basename
#  system "/usr/local/bin/convert '#{entry}' -resize #{scale}% '#{target}/#{basename}'" 
  system "/usr/local/bin/convert '#{entry}' -resize #{width} '#{target}/#{basename}'" 

  puts "'#{basename}' -> './#{width}/#{basename}'"
end
