require 'barby'
require 'barby/barcode'
require 'barby/barcode/qr_code'
require 'barby/outputter/png_outputter'

str = 'Hello QrCode!! Using Gem for Barby, Barby-pngOutputter and Chunky-PNG.'

b = Barby::QrCode.new(str, level: :q, size: 10)
File.open('qr.png', 'w') do |f|
  f.write b.to_png
  f.close
end
