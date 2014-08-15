require 'pathname'
require 'chunky_png'

filename = "3.pdf"
filepath = Pathname.new(filename)

Dir.mkdir(filepath.parent + "tmp") unless (filepath.parent + "tmp").exist?

# Dir.chdir(filepath.parent + "tmp")

`convert -density 300 -size 1024x800 3.pdf tmp/3-%03d.png`

puts "Loading from qr"
img_1 = ChunkyPNG::Image.from_file("qr.png")

# To pdf
Dir.chdir("tmp")
a = Dir.glob("*")
a.each do |f|
  puts "Loading #{f}"
  image = ChunkyPNG::Image.from_file(f)
  image.compose!(img_1, 500, 10)
  image.save("1.png", :fast_rgba)
  # ChunkyPNG::Image.from_file(f).compose!(img_1, 500, 10).save(f+"-0")
end
# string = ""
string = Dir.glob("*").join(" ")

`convert #{string} -quality 100 -units PixelsPerInch -density 150x150 out.pdf`





