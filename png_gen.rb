require 'RMagick'
require 'rqrcode_png'

canvas = Magick::Image.new(1024, 300) { self.background_color = "none" }
gc = Magick::Draw.new
gc.pointsize(14)
text = "ID: EX-0001\nCategories: Simple Past, Past Continuous, Pronouns, Preposition"
gc.text(30, 70, text)
gc.draw(canvas)
canvas.write("tmp.png")

qr = RQRCode::QRCode.new("EX-0001", :size => 4, :level => :h)
png = qr.to_img
png.resize(90,90).save("qr.png")

