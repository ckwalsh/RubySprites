require 'sprites/sprite'

# This is testing the packing ability.  It should generate a sprite.png
# file with all the images in the imgs/ directory
sp = Sprites::Sprite.new('../sprite.png', 'imgs')

f = Dir.new('imgs').entries
f.delete_if {|file|
  !(file =~ /\.((png)|(gif))$/)
}
sp.add_images(f)

sp.update(true, false)

# This is testing the css modifier.  It first generates an image named
# csstest.png based on the css file, then modifies that css file to use the generated sprite

Sprites::Sprite.update_from_css(File.read('spritetest.css'), '.') {|x| "csstest.png"}
puts Sprites::Sprite.process_css(File.read('spritetest.css'), '.') {|x| "csstest.png"}
