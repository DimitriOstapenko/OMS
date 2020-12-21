require 'barby'
require 'barby/barcode/code_128'
require 'barby/outputter/png_outputter'

barcode = Barby::Code128.new('The noise of mankind has become too much')
File.open('code128.png', 'w'){|f|
  f.write barcode.to_png(:height => 20, :margin => 5)
}
