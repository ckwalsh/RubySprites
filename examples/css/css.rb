current_dir = File.dirname(__FILE__)

$:.unshift File.join(current_dir, '../../lib')

require 'lash-sprites/sprite'
require 'lash-sprites/css'

sprite = RubySprites::Sprite.new('css/sprite.png', current_dir + '/..')
    
(1..60).each do |x|
  sprite.add_image("example_imgs/#{x}.png")
end

sprite.update

puts RubySprites::CSS.generate(sprite)
RubySprites::CSS.generate(sprite, 'css/css.css')
