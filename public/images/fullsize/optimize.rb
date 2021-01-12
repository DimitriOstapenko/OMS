# Optimize full resolution images to reduce size and maintain same width
# Put optimized images into subdirectory '2000' and add 'optimized' comment
# Run from fullsize directory, then move images to /images
#
# ARG: none
#
# N.B! convert/identify paths as well as backup_dir are platform-dependent 
#
require_relative '../config/environment'
require 'pathname'
require 'fileutils'

width = '2000' 
base_dir = IMAGE_BASE.join('fullsize')
target_dir = base_dir.join(width)
backup_dir = Pathname.new("/media/seagate/oms/images/fullsize_orig/")

Dir.mkdir(target_dir) unless File.exists?(target_dir)
puts "** Converting new images in #{target_dir} to standard width of #{width}px"

Pathname.glob("#{base_dir}/[TLG]*.jpg").sort.each do |entry|
  basename = entry.basename('.*')
  extname = entry.extname
  comment = `/usr/bin/identify -format %c '#{entry}'`

# skip already optimized images  
  next if comment.match(/^optimized/)
  system "/usr/bin/convert '#{entry}' -strip -sampling-factor 4:2:0 -quality 85 -interlace JPEG -colorspace RGB  -resize #{width} -set comment 'optimized with imagemagick'  '#{target_dir}/#{basename}.jpg'"
  FileUtils.cp(base_dir.join(entry), backup_dir)
#  puts "copied #{entry} to #{backup_dir}"
  FileUtils.mv(target_dir.join(entry.basename), entry)
#  puts "copied #{entry.basename} back to #{base_dir}"
  puts "#{basename}#{extname} - converted"
end
puts "All done.."
