module RubySprites
  module GraphicsManager
    def initialize(sprite)
      @sprite = sprite
    end
    
    def combine(images, width, height)
      raise "Must be overridden"
    end

    def get_info(image)
      raise "Must be overridden"
    end
  end
end