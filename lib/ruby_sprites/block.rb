module RubySprites
  class Block

    attr_reader :x, :y, :width, :height

    def initialize(x, y, width, height)
      @x = x
      @y = y
      @width = width
      @height = height
    end

    def fits?(img)
      return img.width <= @width && img.height <= @height
    end

    def split(img)
      blocks = []
      if (@width - img.width) * img.height > (@height - img.height) * img.width
        blocks.push Block.new(@x + img.width, @y, @width - img.width, @height) if @width != img.width
        blocks.push Block.new(@x, @y + img.height, img.width, @height - img.height) if @height != img.height
      else
        blocks.push Block.new(@x + img.width, @y, @width - img.width, img.height) if @width != img.width
        blocks.push Block.new(@x, @y + img.height, @width, @height - img.height) if @height != img.height
      end
      return blocks
    end

    def area
      return @width * @height
    end
  end
end
