################################################################################
# RubySprites
#   This module allows easy dynamic generation of css sprites from many image
#   files. Can also dynamically modify css to use sprited images, taking into
#   account file modifications.
#   
#   Dependencies
#     RMagick 2.0+ OR GD2 rubygem.  Defaults to RMagick
#     pngcrush if you want to decrease the size of generated png files
#
#   Author
#     Cullen Walsh - ckwalsh@u.washington.edu
#
#   License
#     This file is part of RubySprites.
#     
#     RubySprites is free software: you can redistribute it and/or modify
#     it under the terms of the GNU Lesser General Public License as published
#     by the Free Software Foundation, either version 3 of the License, or
#     (at your option) any later version.
#
#     RubySprites is distributed in the hope that it will be useful,
#     but WITHOUT ANY WARRANTY; without even the implied warranty of
#     MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#     GNU Lesser General Public License for more details.
#
#     You should have received a copy of the GNU Lesser General Public License
#     along with RubySprites.  If not, see <http://www.gnu.org/licenses/>.
#
#   Special Thanks
#     WhitePages.com - This module was invisioned and written during my
#     internship with WhitePages.  Their support and guidance was very helpful
#     in making this become what it is today.
################################################################################

module RubySprites

  class Sprite

    ### self.process_css ###
    # Description
    #   Parses the css and replaces singleton images with the sprited image if
    #   the singleton image exists in the sprite and it is not out of date.
    #   Replacements only occur to absolute paths (aka, starting with /) to
    #   prevent relative location  voodoo from occuring since we do not know
    #   the destination of the css.
    # Parameters
    #   css (String)
    #     The css to process and modify
    #   web_root (String)
    #     The path, relative or absolute, corresponding to the document root
    #     location on the server.  All paths taken from the css are assumed to
    #     be relative from here.
    #   <block>
    #     If a block is passed to this method, urls are passed to the block
    #     before they are processed.  Blocks may return true/false to specify a
    #     whether the specified image should be sprited, but may also return a
    #     path relative to the web_root specifying where the resulting sprite
    #     should be located.  If the sprite location is not specified, it is
    #     placed at web/root/path/sprite.png.
    # Returns
    #   css with appropriate background and background-image attributes
    #   replaced.
    def self.process_css(css, web_root)
      sprite_matches = []

      is_url_regex = /url\(.+\)/
      url_regex = /(?:.*)url\((['"]?)(.+)\1\)/
      replacement_regex = /(.*)url\(.+\).*/
      attr_regex = /.*url\(.+\)/
      offset_regex = /(?:(0|-?\d+)px)\s+(?:(0|-?\d+)px)?/
      attr_repl_regex = /(?:(0|-?\d+)px)\s+(?:(0|-?\d+)px)?/
      space_regex = /\s{2,}/

      css.scan(/(background(?:-image)?)\:([^;]+)(?:;|\})/) do |match|
        complete = $&
        attribute = $1
        modifiers = $2.strip

        # Don't do any more unless we are given a URL
        next unless modifiers =~ is_url_regex
        url = modifiers.match(url_regex)
        next if url.nil?
        url = url[2]
        # We only want absolute paths
        next unless url[0,1] == '/'
        replacement = modifiers.gsub(replacement_regex, '\1url(%s)')

        if attribute == 'background-image'
          offsets = [0,0]
          replacement += " %dpx %dpx"
        else
          attr_rest = modifiers.gsub(attr_regex, '').chomp
          # At this point, we aren't supporting repeating sprites
          next if attr_rest.include?('repeat-')

          # Check if this is already part of a combined sprite image.  If so, we need to manually change the offsets
          offsets = attr_rest.match(offset_regex)
          if offsets.nil?
            offsets = [0, 0]
          else
            offsets = [offsets[1].to_i, offsets[2].to_i]
          end

          replacement += attr_rest.gsub(attr_repl_regex, ' ') + ' %dpx %dpx;'
        end

        replacement = ('background: ' + replacement).gsub(space_regex, ' ')
        sprite_matches.push [complete, replacement, url, offsets]
      end

      sprites = {}

      images = sprite_matches.collect { |m| m[2] }
      images.uniq!

      translations = {}

      images.each do |img|
        sprite_file = block_given? ? yield(img) : true
        next unless sprite_file

        sprite_file = 'sprite.png' if sprite_file === true
        sprites[sprite_file] = new(sprite_file, web_root) if sprites[sprite_file].nil?

        translations[img] = {
          :sprite => sprites[sprite_file],
          :coords => sprites[sprite_file].image_coords(img)
        } if sprites[sprite_file].current?(img)
      end
      
      css_result = css

      sprite_matches.each do |match|
        trans = translations[match[2]]
        unless trans.nil?
          x = match[3][0] - trans[:coords][0]
          y = match[3][1] - trans[:coords][1]
          repl = sprintf(match[1], "/#{trans[:sprite].filename}?#{trans[:sprite].mtime}", x, y)
          css_result.gsub!(match[0], repl)
        end
      end

      return css_result
    end
    
    ### self.update_from_css ###
    # Description
    #   Parses the css and generates sprites based on the images referenced in
    #   background and background-image attributes.  It applies pngcrush to the
    #   generated files.
    # Parameters
    #   css (String)
    #     The css to process
    #   web_root (String)
    #     The path, relative or absolute, corresponding to the document root
    #     location on the server.  All paths taken from the css are assumed to
    #     be relative from here.
    #   <block>
    #     If a block is passed to this method, urls are passed to the block
    #     before they are processed.  Blocks may return true/false to specify a
    #     whether the specified image should be sprited, but may also return a
    #     path relative to the web_root specifying where the resulting sprite
    #     should be located.  If the sprite location is not specified, it is
    #     placed at web/root/path/sprite.png.
    def self.update_from_css(css, web_root)
      imgs = {}

      is_url_regex = /url\(.+\)/
      url_regex = /(?:.*)url\((['"]?)(.+)\1\)/

      css.scan(/(background(?:-image)?)\:([^;]+)(?:;|\})/) do |match|
        complete = $&
        attribute = $1
        modifiers = $2.strip

        # Don't do any more unless we are given a URL
        next unless modifiers =~ is_url_regex 
        url = modifiers.match(url_regex)
        next if url.nil?
        url = url[2]
        # We only want absolute paths
        next unless url[0,1] == '/'
        sprite_file = block_given? ? yield(url) : true
        next unless sprite_file
        sprite_file = 'sprite.png' if sprite_file === true
        imgs[sprite_file] ||= []
        imgs[sprite_file].push url
      end

      imgs.each do |sprite_file, images|
        s = new(sprite_file, web_root)
        images.uniq!
        images.each do |i|
          s.add_image(i) if File.exists?(web_root + i)
        end
        s.update(true)
      end
    end
    
    ###########################################################################

    attr_reader :filename, :mtime
    
    @@DEFAULT_OPTIONS = {
      :graphics_engine => 'rmagick',
      :pack_dir => 'down',
      :force_update => false,
      :crush_sprite => false,
    }

    ### new ###
    # Description
    #   Creates a new sprite, or opens a sprite that already exists.
    # Parameters
    #   filename (String)
    #     The file path of the sprite file, relative to the root_path 
    #   root_path (String)
    #     The relative or absolute path to a folder that will serve as the root
    #     for all image paths
    # Returns
    #   New sprite object
    def initialize(filename, root_path = nil, options = {})

      @options = @@default_options.merge(options)

      @root_path = File.expand_path((root_path.nil?) ? '.' : root_path)
      @root_path += '/' unless @root_path[-1, 1] == '/'
      
      @filename = filename

      @file = File.expand_path("#{@root_path}/#{@filename}")
      
      @width = 0
      @height = 0
      @blocks = []
      @image_queue = []
      @images = {}
      
      if File.exists?(@file) && File.exists?("#{@file}.sprite")
        read_data
        @mtime = File.mtime(@file).to_i
      end
    end

    ### clear ###
    # Description
    #   Resets the sprite to a clean state, containing no images and of 0x0
    #   size.  If the sprite file exists on the system, it is deleted.
    def clear
      File.unlink @file if File.exists? @file
      File.unlink sprite_file if File.exists? sprite_file
      initialize(@file.gsub(@root_path, ''), @root_path)
    end

    ### sprite_file ###
    # Description
    #   Returns the path to the sprite information file
    # Returns
    #   Path to the sprite information file
    def sprite_file
      return @file + '.sprite'
    end

    ### current? ###
    # Description
    #   Determines whether the image exists within the sprite, and if it does,
    #   whether the image has been modified since the sprite was generated.
    # Parameters
    #   imagepath (String)
    #     Path to an image relative to the sprite's root_path
    # Returns
    #   True if the image exists in the sprite and has not been modified since
    #   the sprite was last generated, false otherwise.
    def current?(imagepath)
        img = @images[imagepath]
        return !img.nil? && img.exists? && img.mtime < @mtime
    end
    
    ### image_coords ###
    # Description
    #   Returns the coordinates and dimensions of the specified image if it
    #   exists in the sprite.
    # Parameters
    #   imagepath (String)
    #     Path to an image relative to the sprite's root_path
    # Returns
    #   nil if the file does not exist in the generated sprite, position data in
    #   the form of [x, y, width, height] otherwise.
    def image_coords(imagepath)
      return nil if @images[imagepath].nil?
      return [@images[imagepath].x, @images[imagepath].y, @images[imagepath].width, @images[imagepath].height]
    end

    ### add_image ###
    # Description
    #   Adds the image specified by the path to the sprite if it does not
    #   already exist.
    # Parameters
    #   img_path (String)
    #     Path to an image relative to the sprite's root_path
    def add_image(img_path)
      @image_queue.push Image.new(img_path, @root_path, 0, 0) if @images[img_path].nil?
    end
    
    ### add_images ###
    # Description
    #   Adds the images specified by the array of paths to the sprite if they do
    #   not exist in the sprite.
    # Parameters
    #   img_paths (Array[String])
    #     Array of paths to images relative to the sprite's root_path
    def add_images(img_paths)
      img_paths.each do |img|
        add_image(img)
      end
    end
    
    ### update ###
    # Description
    #   Updates the sprite file on the disk if needed, and may use png crush to
    #   decrease the file size.
    # Parameters
    #   crush (Boolean)
    #     Determines whether to attempt to execute pngcrush to decrease the size
    #     of the generated sprite.  If pngcrush is not installed, nothing will
    #     happen.
    #   force (Boolean)
    #     Decides whether to force a disk update.  By default, if the sprite
    #     believes all the images it contains are up to date, it will not
    #     generate a new image.
    def update(crush = true, force = false)
      update = force || !@image_queue.empty? || @mtime.nil?
      @images.each do |id, img|
        if img.mtime.nil? || img.mtime > @mtime
          update = true
          break
        end
      end
      if update
        pack
        write_file
        write_data
        if crush
          system("pngcrush #{@file} #{@file}.crush")
          FileUtils.mv("#{@file}.crush", @file) if File.exists? "#{@file}.crush"
        end
      end
    end
    
    protected
    
    # Writes the sprite image
    def write_file
      image = Magick::Image.new(@width, @height)
      @images.each do |path, img|
        img.draw(image)
      end
      image.write(@file)

#      shade = 0;
#      image = Magick::Image.new(@width, @height)
#      @blocks.each do |block|
#        drawer = Magick::Draw.new
#        drawer.fill("#" + shade.to_s * 6)
#        shade = (shade + 1) % 10
#        drawer.rectangle(block.x, block.y, block.x - 1 + block.width, block.y - 1 + block.height)
#        drawer.draw(image)
#      end
#      image.write("#{@file}.sh.png")
    end
    
    def read_data
      return unless File.exists? sprite_file
      lines = File.readlines(sprite_file)
      return if lines.empty?
      dims = lines.delete_at(0).chomp.split(' ')
      @width = dims[0].to_i
      @height = dims[2].to_i
      lines.each do |line|
        line_parts = line.chomp.split(' ')
        if line_parts[0] == 'B'
          @blocks.push Block.new(line_parts[1].to_i, line_parts[2].to_i, line_parts[3].to_i, line_parts[4].to_i)
        elsif line_parts[0] == 'I'
          img = Image.new(line_parts[1], @root_path, line_parts[2].to_i, line_parts[3].to_i, line_parts[4].to_i, line_parts[5].to_i)
          @images[img.path] = img
        end
      end
    end
    
    def write_data
      lines = []
      lines.push "#{@width} x #{@height}"
      @blocks.each do |block|
        lines.push "B #{block.x} #{block.y} #{block.width} #{block.height}"
      end
      @images.each do |img_path, img|
        lines.push "I #{img_path} #{img.x} #{img.y} #{img.width} #{img.height}"
      end
      fp = File.open(sprite_file, 'w')
      fp.write(lines.join("\n"))
      fp.close
    end
    
    def pack
      @width = 0
      @height = 0
      @blocks = []
      @image_queue.concat @images.values
      @images = {}
      @image_queue.sort! {|a, b|
        if b.width == a.width
          b.height <=> a.height
        else
          b.width <=> a.width
        end
      }
      @image_queue.each do |img|
        next unless img.exists?
        smallest_match = nil
        smallest_exact = nil
        img_area = img.area
        @blocks.each do |block|
          if block.fits?(img)
            if img.width == block.width || img.height == block.height
              if img_area == block.area
                smallest_match = block
                smallest_exact = block
                break
              end
              smallest_exact = block if(smallest_exact.nil? || block.area < smallest_exact.area)
            end
            smallest_match = block if(smallest_match.nil? || block.area < smallest_match.area)
          end
        end
        if !smallest_exact.nil?
          img.x = smallest_exact.x
          img.y = smallest_exact.y
          @images[img.path] = img
          
          @blocks.concat @blocks.delete(smallest_exact).split(img)
        elsif !smallest_match.nil?
          img.x = smallest_match.x
          img.y = smallest_match.y
          @images[img.path] = img
          @blocks.concat @blocks.delete(smallest_match).split(img)
        else
          if img.width > @width
            @blocks.push Block.new(@width, 0, img.width - @width, @height) if @height > 0
            @width = img.width
          end
          img.x = 0
          img.y = @height
          @images[img.path] = img
          @blocks.concat Block.new(0, @height, @width, img.height).split(img)
          @height += img.height
        end
      end
      @image_queue = []
    end
  end
end
