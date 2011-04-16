require 'bundler'
Bundler::GemHelper.install_tasks
 
require 'rubygems'

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

  puts ""

  require 'test/t_rmagick'
  require 'test/t_gd2'
  puts ""

end

desc 'Benchmark availible graphics backends and packing algorithms'
task :benchmark do
  puts "== Benchmarking Graphics Engines =="
  require 'test/b_graphics'
  puts "== Benchmarking Packing algorithms =="
  require 'test/b_packers'
end

