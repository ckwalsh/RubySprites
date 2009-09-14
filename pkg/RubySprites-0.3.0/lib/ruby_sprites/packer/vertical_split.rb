require 'ruby_sprites/image'
require 'ruby_sprites/block'

module RubySprites
  module Packer
    module VerticalSplit

      def self.pack(images, options = {})
        width = 0
        height = 0
       
        images = images.dup

        images.sort! do |a, b|
          a.width <=> b.width
        end

        # Grab the widest image to use as a static width
        i = images.pop
        width = i.width
        height = i.height
        i.x = 0
        i.y = 0

        images.sort! do |a, b|
          a.area <=> b.area
        end

        block_heap = Heap.new {|a,b| b.area <=> a.area}

        while !images.empty?
          # This actually runs each loop, but we have the if here just in case
          if block_heap.empty?
            # There aren't any blocks to put anything in, so lets make some
            img = images.pop
            if width == 0 && height == 0
              img.x = 0
              img.y = 0
              width = img.width
              height = img.height
            else
              if img.width > width
                block_heap.insert(Block.new(width, 0, img.width - width, height))
                width = img.width
              elsif img.width < width
                block_heap.insert(Block.new(img.width, height, width - img.width, img.height))
              end
              img.x = 0
              img.y = height
              height += img.height
            end
          else
            while !block_heap.empty? && !images.empty?
              # We are looping through the blocks we have from smallest to biggest, then images smallest to biggest.
              # We find the largest image that can fit in the current block, then put it there.  If no images fit,
              # the block is thrown out.
              block = block_heap.remove
              cur_img = nil
              cur_exact = nil
              images.each_index do |i|
                cur_img = i if block.fits?(images[i])
                cur_exact = i if block.fits?(images[i]) && (block.width == images[i].width || block.height == images[i].height)
              end
              if !cur_exact.nil?
                # We prefer when one of the dimensions matches
                img = images.delete_at(cur_exact)
                img.x = block.x
                img.y = block.y
                split_block(block, img).each do |b|
                  block_heap.insert(b)
                end
              elsif !cur_img.nil?
                # Best we can find
                img = images.delete_at(cur_img)
                img.x = block.x
                img.y = block.y
                split_block(block, img).each do |b|
                  block_heap.insert(b)
                end
              else
                # Nothing will fit in this block, we are throwing it out
              end
            end
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

      protected

      class Heap
        def initialize(&comparer)
          @comparer = comparer
          @heap = [0]
        end

        def insert(el)
          pos = @heap.length
          @heap.push(el)
          new_pos = pos
          while new_pos != 1 &&  @comparer.call(el, @heap[new_pos / 2]) < 0
            new_pos /= 2
          end

          while(pos > new_pos)
            @heap[pos] = @heap[pos / 2]
            pos /= 2
          end
          @heap[pos] = el
        end

        def remove
          return nil if @heap.length == 1
          el = @heap[1]
          shifter = @heap.pop
          if @heap.length != 1
            pos = 1
            while(!@heap[pos * 2].nil?)
              lesser_pos = pos * 2
              lesser_pos += 1 if !@heap[pos * 2 + 1].nil? && @comparer.call(@heap[pos * 2 + 1], @heap[pos * 2]) < 0
              if(@comparer.call(@heap[lesser_pos], shifter) < 0)
                @heap[pos] = @heap[lesser_pos]
                pos = lesser_pos
              else
                break
              end
            end

            @heap[pos] = shifter
          end
          return el
        end

        def peek
          return nil if @heap.length == 1
          return @heap[1]
        end

        def empty?
          return @heap.length == 1
        end

        def inspect
          return @heap.to_s
        end
      end
    end
  end
end
