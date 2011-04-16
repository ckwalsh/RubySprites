require 'ruby_sprites/graphics_manager/graphics_manager'

module RubySprites
  module GraphicsManager
    class Rmagick < GraphicsManager

      DESCRIPTION = 'RMagick'

      def self.availible?
        begin
          require 'rubygems'
          require 'RMagick'
        rescue LoadError
          return false
        end
        
        return Magick::Version.match(/^RMagick 2/)
      end

      def combine(images, width, height)
        image = Magick::Image.new(width, height) { self.background_color = '#0000' }
        images.each do |path, img|
          next unless img.exists?
          i = Magick::Image.read(@sprite.file_root + path).first
          drawer = Magick::Draw.new
          w = width - img.x
          w = img.width if img.width < w
          h = height - img.y
          h = img.height if img.height < h
          drawer.composite(img.x, img.y, w, h, i)
          drawer.draw(image)
          i.destroy!
        end
        image.write(@sprite.image_file)
      end

      def get_info(path)
        img = Magick::Image.read(@sprite.file_root + path).first
        info = {:width => img.columns, :height => img.rows}
        img.destroy!
        return info
      end
    end
  end
end
