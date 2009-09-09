current_dir = File.dirname(__FILE__)

$:.unshift File.join(current_dir, '../../lib')

require 'ruby_sprites/sprite'


pack_types = [:vertical_stack, :horizontal_stack, :vertical_smart, :horizontal_smart, :both_smart, :even, :ratio, :both_split, :vertical_split, :horizontal_split]

pack_types = [:both_smart, :both_split, :vertical_split, :horizontal_split]

pack_types.each do |pack|
  sprite = RubySprites::Sprite.new("packing/#{pack.to_s}.png", current_dir + '/..', {:pack_type => pack, :force_update => true})
  (1..60).each do |x|
    sprite.add_image("example_imgs/#{x}.png")
  end

  sprite.update
end
