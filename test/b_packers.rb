#!/usr/bin/ruby

test_dir = File.dirname(__FILE__)

$:.unshift File.join(test_dir, '../lib')

require 'ruby_sprites/sprite'
require 'benchmark'

n = 50
puts "#{n} Iterations"

file_data = []

Benchmark.bmbm(17) do |r|
  Dir.entries(File.join(test_dir, '../lib/ruby_sprites/packer')).sort.each do |f|
    next unless f.match(/\.rb$/)
    
    class_name = f.gsub('.rb', '').capitalize.gsub(/_([a-z]+)/) {|x| $1.capitalize}
    file_name = f.gsub('.rb', '')
    
    require "ruby_sprites/packer/#{file_name}"
    
    sprite = RubySprites::Sprite.new("#{class_name}.png", test_dir, {:force_update => true, :pack_type => file_name})
    
    (1..60).each do |x|
      sprite.add_image("imgs/#{x}.png")
    end
    
    sprite.update

    file_data.push [class_name, sprite.width, sprite.height, File.size(File.join(test_dir, "#{class_name}.png"))]
    
    r.report(class_name) {
      n.times {
        sprite = RubySprites::Sprite.new("#{class_name}.png", test_dir, {:force_update => true, :write_files => false, :pack_type => file_name})
        (1..60).each do |x|
          sprite.add_image("imgs/#{x}.png")
        end

        sprite.update
      }
    }
  end
end

puts ""
puts "File size Results"

file_data.each do |data|
  printf("%17s %8d x %5d   (%d bytes)\n", data[0], data[1], data[2], data[3])
end

