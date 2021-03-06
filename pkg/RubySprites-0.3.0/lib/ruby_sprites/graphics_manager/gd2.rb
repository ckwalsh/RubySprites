require 'ruby_sprites/graphics_manager/graphics_manager'

module RubySprites
  module GraphicsManager
    class Gd2 < GraphicsManager

      DESCRIPTION = 'GD2'

      def self.availible?
        begin
          require 'rubygems'
          require 'gd2'
        rescue LoadError
          return false
        end

        return true
      end

      def combine(images, width, height)
        image = GD2::Image.new(width, height)
        images.each do |path, img|
          next unless img.exists?
          i = GD2::Image.import(@sprite.file_root + path)
          w = width - img.x
          w = img.width if img.width < w
          h = height - img.y
          h = img.height if img.height < h
          image.copy_from(i, img.x, img.y, 0, 0, w, h)
          i = nil
        end
        image.export(@sprite.image_file)
      end

      def get_info(path)
        img = GD2::Image.import(@sprite.file_root + path)
        info = {:width => img.width, :height => img.height}
        img = nil
        return info
      end
    end
  end
end
