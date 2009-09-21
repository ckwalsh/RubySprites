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
      :graphics_manager => nil, # The image engine to use, may be :rmagick or :gd2
      :pack_type => 'vertical_split', # Which algorithm should be used to pack images
      :force_update => false, # Should the sprite image be forced to update, even if it appears up to date?
      :write_files => true, # Decides whether the script should actually write the sprite and image files, used mainly for testing.
      :repeat => false # Whether the sprite repeats horizontally or vertically
    }

    # Lets one programatically override the default option values if you are
    # generating multiple sprites
    def self.set_default(key, value)
      @@DEFAULT_OPTIONS[key.to_sym] = value
    end

    attr_reader :filename, :file_root, :image_file, :mtime, :width, :height, :options, :images

    # Creates a sprite object.  Takes an file_root, absolute or relative, a
    # sprite filename relative to the file root, and an options hash.
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
        @mtime = File.mtime(@image_file)
        read_file
      end
    end

    def set_option(key, val)
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
    def image_current?(imagepath)
      img = @images[imagepath]
      return !img.nil? && img.exists? && !@mtime.nil? && img.mtime <= @mtime
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
          if @mtime.nil? || img.mtime.nil? || img.mtime >= @mtime
            update = true
            break
          end
        end
      end
      if update
        pack
        if @options[:write_files]
          write_image unless @height == 0 || @width == 0
          write_sprite_file
        end
        @mtime = Time.now
      end
    end

    @@managers = nil

    def self.graphics_managers
      
      if @@managers.nil?
        @@managers = {}
        
        dir = File.dirname(__FILE__)

        Dir.foreach("#{dir}/graphics_manager") do |file|
          next unless file.match(/\.rb$/)
          begin
            require("#{dir}/graphics_manager/#{file}")
            class_name = file.gsub('.rb', '').capitalize.gsub(/_([a-z]+)/) {|x| $1.capitalize}
            @@managers[file.gsub('.rb', '').to_sym] = GraphicsManager.const_get(class_name) if GraphicsManager.const_get(class_name).availible?
          rescue Exception => a
            puts a
          end
        end
      end

      return @@managers
    end

    # Returns a Graphics manager based on the sprite options that will
    # be used for this sprite.
    def graphics_manager
      if @graphics_manager.nil?
        Sprite.graphics_managers
        if @options[:graphics_manager].nil?
          @graphics_manager = @@managers.values[0].new(self)
        elsif @@managers[@options[:graphics_manager].to_sym].nil?
          throw "Invalid Image Manager"
        else
          @graphics_manager = @@managers[@options[:graphics_manager].to_sym].new(self)
        end
      end
      return @graphics_manager
    end

    protected

    # Writes the sprite image
    def write_image
      case @options[:repeat]
        when :vertical
           graphics_manager.combine(@images, @width, 1)
        when :horizontal
           graphics_manager.combine(@images, 1, @height)
        else
           graphics_manager.combine(@images, @width, @height)
      end
    end

    # Writes the sprite data file
    def write_sprite_file
      lines = []
      lines.push "#{@width} x #{@height}"
      lines.push "Repeat #{@options[:repeat]}" if @options[:repeat]
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

      # This is to handle repeating sprites
      repeat = false
      repeat = lines.delete_at(0).match(/Repeat (\w+)/)[1].to_sym if lines[0] =~ /Repeat \w+/
      # We want to make sure the repeating type matches
      return unless repeat == @options[:repeat]
      @options[:repeat] = repeat

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
      
      @image_queue.each do |img|
        @images[img.path] = img
      end
      @image_queue = []
      
      return if @images.empty?
      
      class_name = @options[:pack_type].to_s.capitalize.gsub(/_([a-z]+)/) {|x| $1.capitalize}

      if @options[:repeat]
        if @options[:repeat] == :vertical
          require "ruby_sprites/packer/horizontal_stack"
          dims = Packer::HorizontalStack.pack(@images.values)
        elsif @options[:repeat] == :vertical
          require "ruby_sprites/packer/vertical_stack"
          dims = Packer::VerticalStack.pack(@images.values)
        else
          throw Exception.new('Invalid repeat type')
        end
      else
        begin
          dims = Packer.const_get(class_name.to_sym).pack(@images.values)
        rescue NameError
          require "ruby_sprites/packer/#{@options[:pack_type].to_s}"
          dims = Packer.const_get(class_name.to_sym).pack(@images.values)
        rescue LoadError
          throw Exception.new('pack_type is invalid')
        end
      end

      @width = dims[:width]
      @height = dims[:height]

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
