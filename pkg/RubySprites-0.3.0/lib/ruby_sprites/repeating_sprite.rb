require 'ruby_sprites/sprite'

module RubySprites
  class RepeatingSprite < Sprite

    def initialize(filename, file_root, options = {})
      raise "Repeating direction not specified" if options[:repeat].nil?
      raise "Invalid repeat direction" unless options[:repeat] == :x || options[:repeat] == :y
      super(filename, file_root, options)
    end

    protected
    
    def write_image
      if options[:repeat] == :y
        graphics_manager.combine(@images, @width, 1)
      else
        graphics_manager.combine(@images, 1, @height)
      end
    end

    def pack
      @image_queue.concat @images.values
      @images = {}
      if options[:repeat] == :x
        @width = 1
        @height = 0
        @image_queue.each do |img|
          img.x = 0
          img.y = @height
          @height += img.height
        end
      else
        @width = 0
        @height = 1
        @image_queue.each do |img|
          img.x = @width
          img.y = 0
          @width += img.width
        end
      end
    end
  end
end
