#!/usr/bin/ruby

test_dir = File.dirname(__FILE__)

$:.unshift File.join(test_dir, '../lib')

require 'ruby_sprites/sprite'

puts "Testing RMagick: "
sprite = RubySprites::Sprite.new('sprite.png', test_dir, {:graphics_manager => :rmagick, :force_update => true})
(1..60).each do |x|
  sprite.add_image("imgs/#{x}.png")
end
sprite.update
puts "    Success"

File.unlink(File.join(test_dir, 'sprite.png')) if File.exists? File.join(test_dir, 'sprite.png')
File.unlink(File.join(test_dir, 'sprite.png.sprite')) if File.exists? File.join(test_dir, 'sprite.png.sprite')

puts "Testing GD2: "
sprite = RubySprites::Sprite.new('sprite.png', test_dir, {:graphics_manager => :gd2, :force_update => true})
(1..60).each do |x|
  sprite.add_image("imgs/#{x}.png")
end
sprite.update
puts "    Success"

puts "Testing sprite file reading: "
sprite = RubySprites::Sprite.new('sprite.png', test_dir, {:graphics_manager => :gd2, :force_update => false})
(1..60).each do |x|
  sprite.add_image("imgs/#{x}.png")
end
puts "    Success"

puts "Testing no update:"
sprite.update
puts "    Success"

File.unlink(File.join(test_dir, 'sprite.png')) if File.exists? File.join(test_dir, 'sprite.png')
File.unlink(File.join(test_dir, 'sprite.png.sprite')) if File.exists? File.join(test_dir, 'sprite.png.sprite')
