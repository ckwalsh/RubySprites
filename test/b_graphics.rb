#!/usr/bin/ruby

test_dir = File.dirname(__FILE__)

$:.unshift File.join(test_dir, '../lib')

require 'lash-sprites/sprite'
require 'benchmark'

n = 10
puts "#{n} Iterations"

Benchmark.bmbm(10) do |r|
  RubySprites::Sprite.graphics_managers.each do |key, val|
    r.report("#{val.const_get(:DESCRIPTION)}:") {
      for i in 1..n
        sprite = RubySprites::Sprite.new('sprite.png', test_dir, {:graphics_manager => key, :force_update => true})
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
