#!/usr/bin/ruby

$:.unshift '../lib'

require 'ruby_sprites/sprite'
require 'benchmark'

n = 10

puts "#{n} Iterations"

Benchmark.bmbm(10) do |r|
  r.report("RMagick:") {
    for i in 1..n;
      sprite = RubySprites::Sprite.new('test.png', '.', {:graphics_manager => :rmagick, :force_update => true})
      (1..60).each do |x|
        sprite.add_image("imgs/#{x}.png")
      end
      sprite.update
    end
  }
  r.report("GD2:") {
    for i in 1..n;
      sprite = RubySprites::Sprite.new('test.png', '.', {:graphics_manager => :gd2, :force_update => true})
      (1..60).each do |x|
        sprite.add_image("imgs/#{x}.png")
      end
      sprite.update
    end
  }
  r.report("No force:") {
    for i in 1..n;
      sprite = RubySprites::Sprite.new('test.png', '.', {:graphics_manager => :gd2, :force_update => false})
      (1..60).each do |x|
        sprite.add_image("imgs/#{x}.png")
      end
      sprite.update
    end
  }
end

File.unlink('test.png')
File.unlink('test.png.sprite')
