require 'RGhost'
require 'RMagick'

current_path = Dir.pwd
file_name = "1.pdf"

file_path = current_path + "/" + file_name

pdf_to_convert = RGhost::Convert.new(file_path)
pdf_array = pdf_to_convert.to :png, multipage: true, :resolution => 400
categories = %w(Tenses, Preposition, Pronouns)

text = "Path: #{file_path}\nID: WD-10000012\n"
categories.each do |ele|
  text << ele
end


watermark = Magick::Image.new(2000, 250)
watermark_text = Magick::Draw.new
watermark_text.annotate(watermark, 0, 0, 200, 0, text) do
  self.gravity = Magick::EastGravity
  self.pointsize = 50
  self.font_family = "Arial"
  self.font_weight = Magick::BoldWeight
  self.stroke = "none"
end



pdf_array.each do |page|
  img = Magick::Image.read(page)
  img[0].composite!(watermark, Magick::NorthEastGravity, Magick::HardLightCompositeOp)
  img[0].write "#{current_path}/1.png"
end

