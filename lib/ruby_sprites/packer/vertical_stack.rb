require 'ruby_sprites/image'


module RubySprites
  module Packer
    module VerticalStack

      def pack(images, options = {})
        width = 0
        height = 0
        images.each do |img|
          next unless img.exists?
          img.x = 0
          img.y = height
          width = img.width if img.width > width
          height += img.height
        end
        return {:width => width, :height => height}
      end

    end
  end
end
