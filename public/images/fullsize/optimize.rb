# Optimize full resolution images to reduce size and maintain same width
# Put optimized images into subdirectory '2000'
# Run from fullsize directory, then move images to /images
#
# ARG: none
#
# N.B! convert/identify paths are platform-dependent 
#
require 'pathname'

width = '2000' 

curdir = Pathname.new(Dir.pwd)
target = curdir.join(width)

Dir.mkdir(target) unless File.exists?(target)
puts "** Target dir: #{target} width: #{width}px"

Pathname.glob("#{curdir}/[TLG]*.jpg").sort.each do |entry|
  basename = entry.basename('.*')
  extname = entry.extname
  comment = `/usr/bin/identify -format %c '#{entry}'`

# skip already optimized images  
  next if comment.match(/^optimized/)
  system "/usr/bin/convert '#{entry}' -strip -sampling-factor 4:2:0 -quality 85 -interlace JPEG -colorspace RGB  -resize #{width} -set comment 'optimized with imagemagick'  '#{target}/#{basename}.jpg'"
  puts "'#{basename}#{extname}' -> './#{width}/#{basename}.jpg"
end
