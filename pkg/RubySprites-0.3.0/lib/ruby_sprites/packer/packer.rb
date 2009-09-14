require 'ruby_sprites/image'

module RubySprites
  module Packer
    module FooPacker
      def pack(images, options = {})
        raise "Must be overridden"
      end
    end
  end
end
