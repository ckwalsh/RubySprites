require 'ruby_sprites/graphics_manager'

require 'rubygems'
require 'RMagick'

module RubySprites
  class MagickManager
    include RubySprites::GraphicsManager

    def combine(images, width, height)
      image = Magick::Image.new(width, height)
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
