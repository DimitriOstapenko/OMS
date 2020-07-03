# Optimize full resolution images to reduce size and maintain same width
# Put optimized images into subdirectory
#
# ARG: none
#
require 'pathname'

width = '2000' 

curdir = Pathname.new(Dir.pwd)
target = curdir.join(width)

Dir.mkdir(target) unless File.exists?(target)
puts "** Target dir: #{target} width: #{width}px"

Pathname.glob("#{curdir}/*.jpg").sort.each do |entry|
  basename = entry.basename('.*')
  extname = entry.extname
  comment = `/usr/local/bin/identify -format %c '#{entry}'`

# skip already optimized images  
  next if comment.match(/^optimized/)
  system "/usr/local/bin/convert '#{entry}' -strip -sampling-factor 4:2:0 -quality 85 -interlace JPEG -colorspace RGB  -resize #{width} -set comment 'optimized with imagemagick'  '#{target}/#{basename}.jpg'"
  puts "'#{basename}#{extname}' -> './#{width}/#{basename}.jpg"
end
