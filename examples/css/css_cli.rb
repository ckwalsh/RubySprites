#!/usr/bin/ruby

current_dir = File.dirname(__FILE__)
$:.unshift File.join(current_dir, '../../lib')

require 'ruby_sprites/sprite'
require 'ruby_sprites/css'

if ARGV.length < 2
  puts "Usage: ruby css_cli.rb sprite_image.ext img1.ext img2.ext ..."
  exit
end

sp_file = ARGV.shift

sprite = RubySprites::Sprite.new(sp_file, '.')

sprite.add_images(ARGV)

sprite.update

RubySprites::CSS.generate(sprite, "#{sp_file}.css")
