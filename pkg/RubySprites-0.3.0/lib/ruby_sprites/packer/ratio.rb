require 'ruby_sprites/image'
require 'ruby_sprites/block'

module RubySprites
  module Packer
    module Ratio

      def self.pack(images, options = {})
        width = 0
        height = 0
        
        images.sort! do |a, b|
          ra = 1.0 * a.width / a.height
          rb = 1.0 * b.width / b.height
          ra = 1.0 / ra if ra < 1
          rb = 1.0 / rb if rb < 1
          ra <=> rb
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
              img.x = exact.x
              img.y = exact.y
              blocks.concat(blocks.delete(exact).split(img))
            else
              img.x = smallest.x
              img.y = smallest.y
              blocks.concat(blocks.delete(smallest).split(img))
            end
          else
            if width == 0 && height == 0
              b = Block.new(0, 0, img.width, img.height)
              width = img.width
              height = img.height
              blocks.concat(b.split(img))
            else
              if img.height > height
                new_area_right = width * (img.height - height)
              else
                new_area_right = img.width * (height - img.height)
              end

              if img.width > width
                new_area_below = height * (img.width - width)
              else
                new_area_below = img.height * (width - img.width)
              end

              if new_area_below > new_area_right
                if img.height > height
                  blocks.push(Block.new(0, height, width, img.height - height))
                  height = img.height
                elsif img.height < height
                  blocks.push(Block.new(width, img.height, img.width, height - img.height))
                end
                img.x = width
                img.y = 0
                width += img.width
              else
                if img.width > width
                  blocks.push(Block.new(width, 0, img.width - width, height))
                  width = img.width
                elsif img.width < width
                  blocks.push(Block.new(img.width, height, width - img.width, img.height))
                end
                img.x = 0
                img.y = height
                height += img.height
              end
            end
          end
        end

        return {:width => width, :height => height}
      end

    end
  end
end
