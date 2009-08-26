require 'ruby_sprites/graphics_manager'

require 'rubygems'
require 'gd2'

module RubySprites
  class GdManager
    include GraphicsManager

    def combine(images)
      image = GD2::Image.new(@sprite.width, @sprite.height)
      images.each do |path, img|
        next unless img.exists?
        i = GD2::Image.import(@sprite.file_root + path)
        image.copy_from(i, img.x, img.y, 0, 0, img.width, img.height)
        i = nil
      end
      image.export(@sprite.image_file)
    end

    def get_info
      img = GD2::Image.import(@sprite.file_root + path)
      info = {:width => img.width, :height => img.height}
      img = nil
      return info
    end
  end
end
