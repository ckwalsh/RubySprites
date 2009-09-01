require 'ruby_sprites/image'
require 'ruby_sprites/block'

module RubySprites
  module Packer
    module HorizontalSmart

      def self.pack(images, options = {})
        width = 0
        height = 0
        
        images.sort! do |a, b|
          if a.height == b.height
            b.width <=> a.width
          else
            b.height <=> a.height
          end
        end

        blocks = []

        images.each do |img|
          next unless img.exists?
          smallest = nil
          exact = nil
          blocks.each do |block|
            next unless block.fits?(img)
            
            exact = block if (img.width == block.width || img.height == block.height) && (exact.nil? || block.area < exact.area)
            smallest = block if smallest.nil? || block.area < smallest.area
            
            break if smallest.area == img.area
          end

          if smallest
            if exact
              blocks.concat(split_block(blocks.delete(exact), img))
            else
              blocks.concat(split_block(blocks.delete(smallest), img))
            end
          else
            if width == 0 && height == 0
              b = Block.new(0, 0, img.width, img.height)
              width = img.width
              height = img.height
            else
              b = Block.new(width, 0, img.width, height)
              width += img.width
            end
            blocks.concat(split_block(b, img))
          end
        end

        return {:width => width, :height => height}
      end

      def self.split_block(block, img)
        blocks = []
        img.x = block.x
        img.y = block.y
        if (block.width - img.width) * img.height > (block.height - img.height) * img.width
          blocks.push Block.new(block.x + img.width, block.y, block.width - img.width, block.height) if block.width != img.width
          blocks.push Block.new(block.x, block.y + img.height, img.width, block.height - img.height) if block.height != img.height
        else
          blocks.push Block.new(block.x + img.width, block.y, block.width - img.width, img.height) if block.width != img.width
          blocks.push Block.new(block.x, block.y + img.height, block.width, block.height - img.height) if block.height != img.height
        end
        return blocks
      end
    end
  end
end
