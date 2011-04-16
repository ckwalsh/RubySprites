# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "lash-sprites/version"

Gem::Specification.new do |s|
  s.name        = "lash-sprites"
  s.version     = Lash::Sprites::VERSION
  s.platform    = Gem::Platform::RUBY
  s.authors     = ["Cullen Walsh", "Paul Alexander"]
  s.email       = ["gems@appsinyourpants.com"]
  s.homepage    = "https://github.com/appsinyourpants/lash-sprites"
  s.summary = 'A library to ease the dynamic generation of CSS spritesfrom a list of images or a css file.  Supports multiple image libraries, including GD2 and ImageMagick, and multiple different packing algorithms.'

  s.rubyforge_project = "lash-sprites"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

end
