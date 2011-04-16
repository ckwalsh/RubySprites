module RubySprites
  class Image

    attr_accessor :x, :y
    attr_reader :path, :width, :height

    def initialize(path, sprite, x = 0, y = 0, width = nil, height = nil)
      @path = path
      @sprite = sprite
      @x = x
      @y = y

      @width = nil
      @height = nil

      if exists?
        
        if !sprite.mtime.nil? && mtime < sprite.mtime
          @width = width
          @height = height
        end

        if @width.nil? || @height.nil?
          info = @sprite.graphics_manager.get_info(path)
          @width = info[:width]
          @height = info[:height]
        end
      end
    end

    def exists?
      return File.exists?(@sprite.file_root + @path)
    end

    def area
      return nil if @width.nil?
      @area = @width * @height if @area.nil?
      return @area
    end

    def mtime
      return File.mtime(@sprite.file_root + @path) if exists?
      return nil
    end
  end
end
