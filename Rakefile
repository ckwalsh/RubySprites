$:.unshift 'lib'

require 'ruby_sprites/sprite'

desc 'Run all tests'
task :default => :test

desc 'Determine server compatibility and test components'
task :test do
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

  require 'test/unit_tests'

end
