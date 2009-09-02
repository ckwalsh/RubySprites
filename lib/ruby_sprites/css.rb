require 'ruby_sprites/sprite'

module RubySprites
  class CSS

    def self.generate(sprite, file = nil)
      css = ''
      css_template = ".%s {
  background: url(%s) %dpx %dpx no-repeat;
  height: %dpx;
  width: %dpx;
}\n\n"
      sprite.images.each do |path, image|
        class_name = path[0,path.rindex('.')].gsub('/','_')
        css += sprintf(css_template, class_name, sprite.filename, image.x, image.y, image.height, image.width)
      end

      if file.nil?
        return css
      else
        fp = File.open(sprite.file_root + file, 'w')
        fp.write(css)
        fp.close
      end
    end
  end
end
