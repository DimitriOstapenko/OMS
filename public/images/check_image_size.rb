# check [TLG]*.jpg images in current directory against given target size 
# ARG: "widthxheight" (px)
#
require 'pathname'

target_size = ARGV[0] || '250x167'
width, height = target_size.split('x')
abort "Usage: ruby check_image_size.rb widthxheight" unless (width && width.to_f > 0) && (height && height.to_f > 0)  # 0 if not a number

curdir = Pathname.new(Dir.pwd)

puts "*** list of images with size different from #{target_size} ***"
Pathname.glob("#{curdir}/[GLT]*.jpg").sort.each do |entry|
  basename = entry.basename
  size = `/usr/local/bin/identify -format '%wx%h' '#{entry}'`
  puts "'#{basename}' : '#{size}'" if size != target_size
end

