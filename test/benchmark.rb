#!/usr/bin/ruby

test_dir = File.dirname(__FILE__)

$:.unshift File.join(test_dir, '../lib')

require 'ruby_sprites/sprite'
require 'benchmark'

n = 10

puts "#{n} Iterations"

Benchmark.bmbm(10) do |r|
  r.report("RMagick:") {
    for i in 1..n;
      sprite = RubySprites::Sprite.new('test.png', test_dir, {:graphics_manager => :rmagick, :force_update => true})
      (1..60).each do |x|
        sprite.add_image("imgs/#{x}.png")
      end
      sprite.update
    end
  }
  r.report("GD2:") {
    for i in 1..n;
      sprite = RubySprites::Sprite.new('test.png', test_dir, {:graphics_manager => :gd2, :force_update => true})
      (1..60).each do |x|
        sprite.add_image("imgs/#{x}.png")
      end
      sprite.update
    end
  }
  r.report("No force:") {
    for i in 1..n;
      sprite = RubySprites::Sprite.new('test.png', test_dir, {:graphics_manager => :gd2, :force_update => false})
      (1..60).each do |x|
        sprite.add_image("imgs/#{x}.png")
      end
      sprite.update
    end
  }
end

File.unlink(File.join(test_dir, 'test.png'))
File.unlink(File.join(test_dir, 'test.png.sprite'))
