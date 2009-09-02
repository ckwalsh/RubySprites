current_dir = File.dirname(__FILE__)

$:.unshift File.join(current_dir, '../../lib')

require 'ruby_sprites/sprite'


pack_types = [:vertical_stack, :horizontal_stack, :vertical_smart, :horizontal_smart]

pack_types.each do |pack|
  sprite = RubySprites::Sprite.new("packing/#{pack.to_s}.png", current_dir + '/..', {:pack_type => pack})
  (1..60).each do |x|
    sprite.add_image("example_imgs/#{x}.png")
  end

  sprite.update
end
