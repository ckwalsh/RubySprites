#!/usr/bin/ruby

test_dir = File.dirname(__FILE__)

$:.unshift File.join(test_dir, '../lib')

require 'ruby_sprites/sprite'

def test(label)
  $test_depth ||= 0
  puts('  ' * $test_depth + "Testing #{label}:")
  $test_depth += 1
  yield
  $test_depth -= 1
  puts('  ' * $test_depth + 'Success!')
end

sprite = nil

test('RMagick') {

  test('Sprite Creation') {
    sprite = RubySprites::Sprite.new('sprite.png', test_dir, {:graphics_manager => :rmagick, :force_update => false})
  }

  test('Read Sprite Option') {
    raise "Incorrect sprite option value" unless sprite.options[:force_update] == false
  }

  test('Set Sprite Option') {
    raise "Unable to set sprite option" unless sprite.set_option(:force_update, true) && sprite.options[:force_update] == true
  }

  test('Adding Images') {
    (1..60).each do |x|
      sprite.add_image("imgs/#{x}.png")
    end
  }

  sprite.update
}

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
