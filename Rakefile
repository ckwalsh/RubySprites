require 'rubygems'
require 'rake/gempackagetask'

desc 'Run tests'
task :default => :test

desc 'Determine server compatibility and test components'
task :test do
  $:.unshift 'lib'
  require 'ruby_sprites/sprite'

  puts 'Availible Image Managers'
  RubySprites::Sprite.graphics_managers.values.each { |x|
    puts "\t#{x.const_get(:DESCRIPTION)}"
  }

  puts 'Availible packing algorithms'
  Dir.entries('lib/ruby_sprites/packer').sort.each { |x|
    next unless x.match(/\.rb$/)
    class_name = x.gsub('.rb', '').capitalize.gsub(/_([a-z]+)/) {|x| $1.capitalize}
    puts "\t#{class_name}"
  }

  require 'test/t_rmagick'
  require 'test/t_gd2'

end

desc 'Benchmark availible graphics backends and packing algorithms'
task :benchmark do
  require 'test/b_graphics'
  require 'test/b_packers'
end

spec = Gem::Specification.new do |s|
  s.name    = 'RubySprites'
  s.version = '0.3.0'
  s.author  = 'Cullen Walsh'
  s.email   = 'ckwalsh@u.washington.edu'
  s.homepage = 'http://ckwalsh.github.com/RubySprites/'
  s.platform = Gem::Platform::RUBY
  s.summary = 'A library to ease the dynamic generation of CSS spritesfrom a list of images or a css file.  Supports multiple image libraries, including GD2 and ImageMagick, and multiple different packing algorithms.'
  s.files = FileList["{docs,examples,lib,test}/**/*"].exclude("rdoc").to_a
  s.require_path = 'lib'
  s.test_file = 'test/unit_tests.rb'
  s.has_rdoc = true
  s.extra_rdoc_files = 'README'
  s.rubyforge_project = 'ruby-sprites'
end

Rake::GemPackageTask.new(spec) do |pkg|
  pkg.need_tar = true
end
