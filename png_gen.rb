require 'RMagick'
require 'rqrcode_png'
require 'oily_png'
require 'fileutils'


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
  img_template.compose!(img_label, x_coord + 255, y_coord)
  rename_file = input_file[5..-1]
  img_template.save("./out-pdf" + rename_file.gsub(".png", "-e.png"), :fast_rgba)
end

generating_qrcode("EX-0001", {height: 250, width: 250})
label = "ID: EX-0001\nCategories: Simple Present, Simple Past, Present Continuous"
generating_label(label, "label.png")

Dir.glob("./doc/*.pdf") do |file|
  renamed_filename = file.gsub(".pdf", "-e.png").gsub("./doc/", "./tmp/")
  puts "Converting to PNG"
  convert_to_png(file, renamed_filename)
  `smusher ./tmp`

  Dir.glob("./tmp/*.*") do |filename|
    puts "Embedding file #{filename}:"
    embed_info(filename, generating_qrcode(file[0..10], {height: 250, width: 250}), "./label.png", 30, 30)
  end

  arr = Dir.glob("./out-pdf/*.*").sort
  puts "Merging into PDF"
  image_list = Magick::ImageList.new(*arr)
  image_list.write(file.gsub(".png", ".pdf").gsub("./doc", "./pro-2"))
  puts "Done"
  puts "Deleting tempfiles"
  FileUtils.rm(Dir.glob("./output/*.*"))
  FileUtils.rm(Dir.glob("./tmp/*.*"))
  FileUtils.rm(Dir.glob("./out-pdf/*.*"))
end


# file = "./doc/pro"
# convert_to_png("./doc/progressgradedgrammar.pdf", "./output/out.png")

# # Dir.mkdir("output-e")
# Dir.glob("./output/*.*") do |filename|
#   embed_info(filename, generating_qrcode("EX-0001", {height: 150, width: 150}), "./label.png", 30, 30)
# end

# arr = Dir.glob("./output/*-e.*").sort
# image_list = Magick::ImageList.new(*arr)
# image_list.write("oo4.pdf")


