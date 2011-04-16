#!/usr/bin/ruby

$test_dir = File.dirname(__FILE__)
$:.unshift File.join($test_dir, '../lib')

require 'test/unit'
require 'test/unit/ui/console/testrunner'
require 'lash-sprites/sprite'
require 'test/t_generic'

unless RubySprites::Sprite.graphics_managers[:rmagick].nil?

class TestRMagick < Test::Unit::TestCase
  include TestGeneric

  def initialize(test_suite)
    super test_suite
  end   

  def setup
    File.unlink($test_dir + '/test.png') if File.exists?($test_dir + '/test.png')
    File.unlink($test_dir + '/test.png.sprite') if File.exists?($test_dir + '/test.png.sprite')

    @sprite = RubySprites::Sprite.new('test.png', $test_dir, {:graphics_manager => :rmagick})
  end
end

Test::Unit::UI::Console::TestRunner.run(TestRMagick)
end
