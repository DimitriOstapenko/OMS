# resize images in current directory and put them into subdirectory [scale]
# ARG: scale (% of original)
#
require 'pathname'

scale = ARGV[0]
abort "Usage: ruby resize.rb %scale" unless (scale && scale.to_f > 0)  # 0 if not a number

curdir = Pathname.new(Dir.pwd)
target = curdir.join(scale)

Dir.mkdir(target) unless File.exists?(target)
puts "** Target dir: #{target} Scale: #{scale}%"

Pathname.glob("#{curdir}/*.jpg").sort.each do |entry|
  basename = entry.basename
  system "/usr/local/bin/convert '#{entry}' -resize #{scale}% '#{target}/#{basename}'" 
  puts "'#{basename}' -> './#{scale}/#{basename}'"
end
