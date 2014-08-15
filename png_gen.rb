require 'RMagick'
require 'rqrcode_png'
require 'oily_png'


# generating text png

def generating_qrcode(string, size)
  qr = RQRCode::QRCode.new(string, :size => 4, :level => :h)
  png = qr.to_img
  png.resize(size[:height], size[:width])
end

def generating_label(labels, output_name)
  canvas = Magick::Image.new(800, 300) do
    self.background_color = "none"
  end
  gc = Magick::Draw.new
  gc.pointsize(14)    # setting font size
  gc.text(30, 70, labels)
  gc.draw(canvas)
  canvas.write(output_name)
end

# Converting PDF to PNG
def convert_to_png(input_pdf, output_file)
  pdf = Magick::ImageList.new(input_pdf) { self.density = 200 }
  pdf.write(output_file)
end

# Adding QR and label to the PNG

def embed_info(input_file, qr, label, x_coord, y_coord)
  img_template = ChunkyPNG::Image.from_file(input_file)
  img_label = ChunkyPNG::Image.from_file(label)
  img_template.compose!(qr, x_coord, y_coord)
  img_template.compose!(img_label, x_coord + 160, y_coord)
  img_template.save(input_file.gsub(".png", "-e.png"), :fast_rgba)
end

generating_qrcode("EX-0001", {height: 150, width: 150})
label = "ID: EX-0001\nCategories: Simple Present, Simple Past, Present Continuous"
generating_label(label, "label.png")
convert_to_png("./doc/progressgradedgrammar.pdf", "./output/out.png")

# Dir.mkdir("output-e")
Dir.glob("./output/*.*") do |filename|
  embed_info(filename, generating_qrcode("EX-0001", {height: 150, width: 150}), "./label.png", 30, 30)
end

arr = Dir.glob("./output/*-e.*").sort
image_list = Magick::ImageList.new(*arr)
image_list.write("oo4.pdf")


