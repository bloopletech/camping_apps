require 'fileutils'
require 'image_science'

require 'digest/md5'

class ImageScience
  WAY_WIDTH = 0
  WAY_HEIGHT = 1

  def forced_thumbnail(size, side = WAY_WIDTH) # :yields: image
    w, h = width, height
    scale = size.to_f / (side == WAY_WIDTH ? w : h)

    self.resize((w * scale).to_i, (h * scale).to_i) do |image|
      yield image
    end
  end

  def portrait?
    height > width
  end

  def landscape?
    width > height
  end

  def square?
    width == height
  end

  #given a width and a height, and a way:
  #if way = width
  #  scale so  width = width, then crop height to height
  #else if way = height
  #  scale so height = height, then crop width to width
  #end
  def cropped_thumbnail2(width, height, side = WAY_WIDTH) # :yields: image
    w, h = self.width, self.height
    scale = (portrait? ? (width / w.to_f) : (height / h.to_f))
    new_height = (h * scale)
    new_width = (w * scale)
    crop_top = [(h > height ? ((new_height - height) / 2) : 0), 0].max
    crop_left = [(w > width ? ((new_width - width) / 2) : 0), 0].max

    self.resize(new_width.round, new_height.round) do |img|
      img.with_crop(crop_left.round, crop_top.round, (new_width - crop_left).round, (new_height - crop_top).round) do |thumb|
        yield thumb
      end
    end
  end
end


module ActiveRecord #:nodoc:
  module HasImage #:nodoc:
    def self.included(base)
      base.extend(ClassMethods)
    end
  
    module ClassMethods
      def has_image(required = true, field_name = 'image', small_size = [25, 25], large_size = [100, 100])
        include ActiveRecord::HasImage::InstanceMethods

        before_save :reset_has_images
        after_save :save_images

        %w(small large).each do |size|
          module_eval <<-EODATA
            def #{field_name}_#{size}(type = :path); #{field_name}(:#{size}, type); end
            def #{field_name}_#{size}_url; #{field_name}(:#{size}, :url); end
            def #{field_name}_#{size}_path; #{field_name}(:#{size}, :path); end
          EODATA
        end
        module_eval <<-EOURL
          def #{field_name}(size = :large, type = :path, has_image = has_#{field_name}?)
            [:small, :large].include?(size) ? "\#{self.class.#{field_name}_path(size, type)}/\#{new_record? ? 'new' : (has_image ? id : 'no_image')}.jpg" : nil
          end

          def #{field_name}_url(size = :large)
            #{field_name}(size, :url)
          end

          def #{field_name}_path(size = :large)
            #{field_name}(size, :path)
          end

          def #{field_name}=(file_data)
            return nil if file_data.nil? || file_data.stat.size == 0
            @image_data ||= {}
            @image_data['#{field_name}'] = [:upload, has_#{field_name}?, file_data, #{small_size.inspect}, #{large_size.inspect}]
          end

          def has_#{field_name}=(has_image)
            old_has_image = has_#{field_name}?
            self[:has_#{field_name}] = has_image
            @image_data ||= {}
            @image_data['#{field_name}'] = [(has_image ? :keep_same : :no_image), old_has_image, nil, #{small_size.inspect}, #{large_size.inspect}] unless @image_data.key? '#{field_name}'
          end

          def has_#{field_name}?
            new_record? ? false : self[:has_#{field_name}]
          end
        
          def self.#{field_name}_path(size = :large, type = :path)
            "\#{type == :path ? $image_server_path || (self.top_level_module::PATH + "/public/images") : $image_server_url || "/images"}/\#{table_name.gsub(table_name_prefix, '')}/#{field_name}/\#{size}"
          end
        EOURL
      
        if required
          module_eval <<-EOURL2
            def validate_#{field_name}
              @image_data ||= {}
              errors.add('#{field_name}'.to_sym, "field requires a file to be uploaded.") if !has_#{field_name}? and !@image_data.key? '#{field_name}'
            end

            validate :validate_#{field_name}
          EOURL2
        end

        FileUtils.mkdir_p(send("#{field_name}_path"), :mode => 0777) unless File.exists?(send("#{field_name}_path"))
      end
    end

    module InstanceMethods
      def reset_has_images
        @image_data ||= {}
        @image_data.each_pair do |field_name, (status, old_status, file_data, small_size, large_size)|
          if status == :keep_same and !old_status and (file_data.nil? or file_data.size == 0)
            @image_data[field_name][0] = :no_image
            self[:"has_#{field_name}"] = false
          end
        end
      end
      def save_images
        @image_data ||= {}
        puts @image_data.inspect
        @image_data.each_pair do |field_name, (status, old_status, file_data, small_size, large_size)|
          [:small, :large].each { |size| File.unlink(send("#{field_name}", size, :path, true)) if File.exists?(send("#{field_name}", size, :path, true)) } if status != :keep_same

          if status == :upload
            #file_data.rewind
            tf = Tempfile.new("temp_image")
            temp = file_data.read
            puts Digest::MD5.hexdigest(temp)
            tf << temp
            tf.flush
            path = tf.path
            puts path
            puts send("#{field_name}_large_path")

            ImageScience.with_image(path) do |img|
              if !large_size[0].nil? and !large_size[1].nil?
                puts "cropped_thumbnail2"
                img.cropped_thumbnail2(large_size[0], large_size[1], ImageScience::WAY_WIDTH) { |thumb| thumb.save send("#{field_name}_large_path") }
              else
                b = (large_size[0].nil? ? [large_size[1], ImageScience::WAY_HEIGHT] : [large_size[0], ImageScience::WAY_WIDTH])
                img.forced_thumbnail(b[0], b[1]) { |thumb| thumb.save send("#{field_name}_large_path") }
              end
              if !small_size[0].nil? and !small_size[1].nil?
                img.cropped_thumbnail2(small_size[0], small_size[1], ImageScience::WAY_WIDTH) { |thumb| thumb.save send("#{field_name}_small_path") }
              else
                b = (small_size[0].nil? ? [small_size[1], ImageScience::WAY_HEIGHT] : [small_size[0], ImageScience::WAY_WIDTH])
                img.forced_thumbnail(b[0], b[1]) { |thumb| thumb.save send("#{field_name}_small_path") }
              end
            end

            tf.close! unless tf.nil?
          end
        end
        return true
      end
    end
  end
end

ActiveRecord::Base.send(:include, ActiveRecord::HasImage)