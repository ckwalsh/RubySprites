require 'ruby_sprites/image'

module RubySprites
  module Packer
    module HorizontalStack

      def self.pack(images, options = {})
        width = 0
        height = 0
        images.each do |img|
          next unless img.exists?
          img.x = width
          img.y = 0
          height = img.height if img.height > height
          width += img.width
        end
        return {:width => width, :height => height}
      end

    end
  end
end
