# Author:: Cullen Walsh
# Copyright:: Copyright (c) 2009 Cullen Walsh
# License:: Lesser General Public License v3

require 'ruby_sprites/image'
require 'ruby_sprites/block'

module RubySprites
  
  # This class is main image sprite creator.  It allows for reading existing
  # sprites, adding images to sprites, and repacking sprites on updates
  class Sprite
    
    # A hash of the default options a sprite uses.  These should be
    # sufficient for most usage.
    @@DEFAULT_OPTIONS = {
      :graphics_manager => :rmagick, # The image engine to use, may be :rmagick or :gd
      :pack_direction => :vertical, # Whether images should be stacked :vertical or :horizontal
      :force_update => false, # Should the sprite image be forced to update, even if it appears up to date?
      :compress_image => false, # Should RubySprites attempt to compress the image to a smaller size?
    }

    # Lets one programatically override the default option values if you are
    # generating multiple sprites
    def self.set_default(key, value)
      @@DEFAULT_OPTIONS[key.to_sym] = value
    end

    attr_reader :filename, :file_root, :image_file, :mtime, :width, :height, :options

    # Creates a sprite object.  Takes an file_root, absolute or relative, a
    # sprite filename relative to the file root, and an options hash.
    #
    # [Availible Options]
    #  * :graphics manager - The graphics engine to use, may be :rmagick or :gd
    #  * :pack direction - The direction sprites should be packed into the image, may be :vertical or :horizontal
    #  * :force_update - Should the sprite image be forced to update, even if it appears up to date? True/False
    #  * :compress_image - Should RubySprites attempt to compress the image to a smaller size? True/False
    def initialize(filename, file_root, options = {})
      @options = @@DEFAULT_OPTIONS.merge(options)

      @file_root = File.expand_path(file_root)
      @file_root += '/' unless @file_root[-1, 1] == '/'
      @filename = filename
      @image_file = File.expand_path(@file_root + @filename)
      @sprite_file = "#{@image_file}.sprite"

      @width = 0;
      @height = 0
      @blocks = []
      @image_queue = []
      @images = {}

      if File.exists?(@image_file) && File.exists?(@sprite_file)
        read_file
        @mtime = File.mtime(@image_file)
      end
    end

    def set_option(key, val)
      raise "Not a valid sprite option" unless @options.has_key?(key.to_sym)
      @options[key.to_sym] = val
    end

    # Destroys the sprite, deleting its related files and freeing up memory
    def destroy!
      File.unlink @image_file if File.exists?(@image_file)
      File.unlink @sprite_file if File.exists?(@sprite_file)
      initialize(@filename, @file_root, @options)
    end

    # Determines if the image in the relative path exists within the sprite
    # and has been updated since hte sprite was generated.
    def image_current?
      img = @images[imagepath]
      return !img.nil? && img.exists? && img.mtime < @mtime
    end

    # Returns the x position, y position, width, and height of the image if
    # it exists in the sprite.
    def image_info(imagepath)
      return nil if @images[imagepath].nil?
      return {:x => @images[imagepath].x,
              :y => @images[imagepath].y,
              :width => @images[imagepath].width,
              :height => @images[imagepath].height,
              :mtime => @images[imagepath].mtime,
              :path => @images[imagepath].path}
    end

    # Adds the image in the relative path to the sprite.
    def add_image(img_path)
      @image_queue.push Image.new(img_path, self, 0, 0) if @images[img_path].nil?
    end

    # Adds the images in the array of relative paths to the sprite.
    def add_images(img_paths)
      img_paths.each do |path|
        add_image(path)
      end
    end

    # Updates the sprite files if it detects changes to the sprite or the
    # force option is set.
    def update
      update = @options[:force_update] || !@image_queue.empty? || @mtime.nil?
      if update
        @images.each do |id, img|
          if img.mtime.nil? || img.mtime > @mtime
            update = true
            break
          end
        end
      end
      if update
        pack
        write_image
        write_sprite_file
      end
    end

    # Returns a Graphics manager based on the sprite options that will
    # be used for this sprite.
    def graphics_manager
      if @graphics_manager.nil?
        case @options[:graphics_manager]
          when :rmagick
            require 'ruby_sprites/magick_manager'
            @graphics_manager = MagickManager.new(self)
          when :gd2
            require 'ruby_sprites/gd_manager'
            @graphics_manager = GdManager.new(self)
        end
      end
      return @graphics_manager
    end

    protected

    # Writes the sprite image
    def write_image
      graphics_manager.combine(@images, @width, @height)
    end

    # Writes the sprite data file
    def write_sprite_file
      lines = []
      lines.push "#{@width} x #{@height}"
      @blocks.each do |block|
        lines.push "B #{block.x} #{block.y} #{block.width} #{block.height}"
      end
      @images.each do |img_path, img|
        lines.push "I #{img_path} #{img.x} #{img.y} #{img.width} #{img.height}"
      end
      fp = File.open(@sprite_file, 'w')
      fp.write(lines.join("\n"))
      fp.close
    end

    # Reads a sprite file and populates the images for this sprite
    def read_file
      return unless File.exists? @sprite_file
      lines = File.readlines(@sprite_file)
      return if lines.empty?
      dims = lines.delete_at(0).chomp.split(' ')
      @width = dims[0].to_i
      @height = dims[2].to_i
      lines.each do |line|
        line_parts = line.chomp.split(' ')
        if line_parts[0] == 'B'
          @blocks.push Block.new(line_parts[1].to_i, line_parts[2].to_i, line_parts[3].to_i, line_parts[4].to_i)
        elsif line_parts[0] == 'I'
          img = Image.new(line_parts[1], self, line_parts[2].to_i, line_parts[3].to_i, line_parts[4].to_i, line_parts[5].to_i)
          @images[img.path] = img
        end
      end
    end

    # Positions the images in the sprite
    def pack
      @width = 0
      @height = 0
      @blocks = []
      @image_queue.concat @images.values
      @images = {}
      sort_images(@image_queue, @options[:pack_direction])

      @image_queue.each do |img|
        next unless img.exists?
        smallest_match = nil
        smallest_exact = nil
        @blocks.each do |block|
          next unless block.fits?(img)
          if img.width == block.width || img.height == block.height
            if img.area == block.area
              smallest_match = block
              smallest_exact = block
              break
            elsif smallest_exact.nil? || block.area < smallest_exact.area
              smallest_exact = block
            end
          end
          if smallest_match.nil? || block.area < smallest_match.area
            smallest_match = block
          end
        end

        split_block(img, smallest_exact || smallest_match)
      end

      @image_queue = []
    end

    # Sorts the sprite images by various rules
    def sort_images(images, order)
      case order
        when :vertical then
          images.sort! {|a, b|
            if b.width == a.width
              b.height <=> a.height
            else
              b.width <=> a.width
            end
          }
        when :horizontal then
          images.sort! {|a, b|
            if b.height == a.height
              b.width <=> a.width
            else
              b.height <=> a.height
            end
          }
        else raise "Invalid sort order"
      end
    end

    # Splits a block in multiple parts if needed to accommodate an image
    def split_block(img, block)
      if block.nil?
        if img.width > @width
          @blocks.push Block.new(@width, 0, img.width - @width, @height) if @height > 0
          @width = img.width
        end
        img.x = 0
        img.y = @height
        @images[img.path] = img
        @blocks.concat Block.new(0, @height, @width, img.height).split(img)
        @height += img.height
      else
        img.x = block.x
        img.y = block.y
        @images[img.path] = img
        @blocks.concat @blocks.delete(block).split(img)
      end
    end
  end
end
