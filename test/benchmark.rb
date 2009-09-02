#!/usr/bin/ruby

test_dir = File.dirname(__FILE__)

$:.unshift File.join(test_dir, '../lib')

require 'ruby_sprites/sprite'
require 'benchmark'

n = 10

puts "#{n} Iterations"
puts RubySprites::Sprite.graphics_managers.join(', ')
Benchmark.bmbm(10) do |r|
  if RubySprites::Sprite.graphics_managers.include?(:rmagick)
    r.report("RMagick:") {
      for i in 1..n;
        sprite = RubySprites::Sprite.new('sprite.png', test_dir, {:graphics_manager => :rmagick, :force_update => true})
        (1..60).each do |x|
          sprite.add_image("imgs/#{x}.png")
        end
        sprite.update
      end
    }
  end
  if RubySprites::Sprite.graphics_managers.include?(:gd2)
    r.report("GD2:") {
      for i in 1..n;
        sprite = RubySprites::Sprite.new('sprite.png', test_dir, {:graphics_manager => :gd2, :force_update => true})
        (1..60).each do |x|
          sprite.add_image("imgs/#{x}.png")
        end
        sprite.update
      end
    }
  end
  r.report("No force:") {
    for i in 1..n;
      sprite = RubySprites::Sprite.new('sprite.png', test_dir, {:force_update => false})
      (1..60).each do |x|
        sprite.add_image("imgs/#{x}.png")
      end
      sprite.update
    end
  }
end

File.unlink(File.join(test_dir, 'sprite.png')) if File.exists? File.join(test_dir, 'sprite.png')
File.unlink(File.join(test_dir, 'sprite.png.sprite')) if File.exists? File.join(test_dir, 'sprite.png.sprite')
