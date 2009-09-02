#!/usr/bin/ruby

$test_dir = File.dirname(__FILE__)
$:.unshift File.join($test_dir, '../lib')

puts "These tests make sure RubySprites is functionally working.  They cannot check if the generated images are correct"
puts "Correctness is most easily checked via the example scripts."

require 'test/unit'
require 'ruby_sprites/sprite'

class TestSprite < Test::Unit::TestCase
 
  def initialize(test_suite)
    super test_suite
    
    @image_managers = []

    require 'rubygems'

    begin
      require 'RMagick'
      @image_managers.push :rmagick
    rescue LoadError
    end

    begin
      require 'GD2'
      @image_managers.push :gd2
    rescue LoadError
    end

  end

  def setup
    File.unlink($test_dir + '/test.png') if File.exists?($test_dir + '/test.png')
    File.unlink($test_dir + '/test.png.sprite') if File.exists?($test_dir + '/test.png.sprite')

    @sprite = RubySprites::Sprite.new('test.png', $test_dir)
  end

  def teardown
    File.unlink($test_dir + 'test.png') if File.exists?($test_dir + 'test.png')
    File.unline($test_dir + 'test.png.sprite') if File.exists?($test_dir + 'test.png.sprite')
    @sprite.destroy!
  end

  def test_add_image
    @sprite.add_image('imgs/1.png')
    assert_equal(0, @sprite.images.length)
    @sprite.update
    assert_equal(1, @sprite.images.length)
    @sprite.add_image('imgs/2.png')
    assert_equal(1, @sprite.images.length)
    @sprite.update
    assert_equal(2, @sprite.images.length)
    @sprite.add_image('imgs/2.png')
    assert_equal(2, @sprite.images.length)
    @sprite.update
    assert_equal(2, @sprite.images.length)
  end

  def test_add_images
    imgs = []
    (1..20).each do |n|
      imgs.push "imgs/#{n}.png"
    end

    @sprite.add_images(imgs)
    assert_equal(0, @sprite.images.length)

    @sprite.update
    assert_equal(20, @sprite.images.length)

    imgs = []
    (11..30).each do |n|
      imgs.push "imgs/#{n}.png"
    end

    @sprite.add_images(imgs)
    assert_equal(20, @sprite.images.length)

    @sprite.update
    assert_equal(30, @sprite.images.length)
  end

  def test_image_info
    assert_equal(nil, @sprite.image_info('imgs/1.png'))

    @sprite.add_image('imgs/1.png')
    assert_equal(nil, @sprite.image_info('imgs/1.png'))

    @sprite.update

    info = @sprite.image_info('imgs/1.png')
    assert_equal(0, info[:x])
    assert_equal(0, info[:y])
    assert_equal(11, info[:width])
    assert_equal(51, info[:height])
    assert_equal('imgs/1.png', info[:path])
    assert_equal(File.mtime('imgs/1.png'), info[:mtime])
  end

  def test_image_current?
    @sprite.add_image('imgs/1.png')

    orig_ctime = File.ctime($test_dir + '/imgs/1.png').to_i
    File.utime(orig_ctime, Time.now.to_i - 1000, 'imgs/1.png')
    
    assert_equal(false, @sprite.image_current?('imgs/1.png'))
    
    @sprite.update
    assert_equal(true, @sprite.image_current?('imgs/1.png'))

    File.utime(orig_ctime, Time.now.to_i + 1000, 'imgs/1.png')

    assert_equal(false, @sprite.image_current?('imgs/1.png'))
    
    @sprite.update

    File.utime(orig_ctime, Time.now.to_i, 'imgs/1.png')
    

    assert_equal(true, @sprite.image_current?('imgs/1.png'))

    File.utime(orig_ctime, Time.now)

  end

  def test_rmagick
    unless @image_managers.include?(:rmagick)
      puts "RMagick Not installed, skipping test"
      return
    end
    # This is checking just for an error to be thrown
    # Manual validation should take place to check if the image is correct
    @sprite.set_option(:graphics_manager, :rmagick)
    @sprite.update

    @sprite.add_image('imgs/1.png')

    @sprite.update
    
    assert_equal(true, File.exists?("#{@sprite.file_root}/test.png"))
  end

  def test_gd
    unless @image_managers.include?(:gd2)
      puts  "GD2 Not installed, skipping test"
      return
    end
    # This is checking just for an error to be thrown
    # Manual validation should take place to check if the image is correct
    @sprite.set_option(:graphics_manager, :rmagick)
    @sprite.update

    @sprite.add_image('imgs/1.png')

    @sprite.update

    assert_equal(true, File.exists?("#{@sprite.file_root}/test.png"))
  end

  def test_pack_vertical
    @sprite.set_option(:pack_type, :vertical_stack)
    
    (1..20).each do |n|
      @sprite.add_image("imgs/#{n}.png")
    end
    
    @sprite.update
  end

  def test_pack_horizontal
    @sprite.set_option(:pack_type, :horizontal_stack)
    
    (1..20).each do |n|
      @sprite.add_image("imgs/#{n}.png")
    end
    
    @sprite.update
  end

  def test_pack_vertical_smart
    @sprite.set_option(:pack_type, :vertical_smart)
    
    (1..20).each do |n|
      @sprite.add_image("imgs/#{n}.png")
    end
    
    @sprite.update
  end
  
  def test_pack_horizontal_smart
    @sprite.set_option(:pack_type, :horizontal_smart)
    
    (1..20).each do |n|
      @sprite.add_image("imgs/#{n}.png")
    end
    
    @sprite.update
  end
end
