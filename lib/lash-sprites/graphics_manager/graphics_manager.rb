module RubySprites
  module GraphicsManager
    class GraphicsManager
      
      def initialize(sprite)
        @sprite = sprite
      end

      def self.availible?
        return false
      end

      def combine(images, width, height)
        raise "Must be overridden"
      end

      def get_info(image)
        raise "Must be overridden"
      end
    end
  end
end
