#!/usr/bin/ruby

current_dir = File.dirname(__FILE__)
$:.unshift File.join(current_dir, '../../lib')

require 'ruby_sprites/sprite'
require 'ruby_sprites/css'

if ARGV.length < 3
  puts "Usage: ruby css_cli.rb repeat-type sprite_image.ext img1.ext [img2.ext] [...]"
  puts "repeat-type may be 'default', 'vertical', or 'horizontal'"
  puts "sprite_image.ext is the output sprite file"
  exit
end

repeat = ARGV.shift
sp_file = ARGV.shift

options = {
  :repeat => (repeat == 'default') ? false : repeat.to_sym,
}

sprite = RubySprites::Sprite.new(sp_file, '.', options)

sprite.add_images(ARGV)

sprite.update

RubySprites::CSS.generate(sprite, "#{sp_file}.css")
