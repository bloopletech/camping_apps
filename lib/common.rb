module StaticAssetsClass
  #TODO: Not actually *needed*, also should not be a massive string
  def self.included(base)
    base.class_eval <<-EOF
      class StaticAssets < R '/(.+)\\\.(css|js|gif|jpg|png|ico|zip|txt|swf|flv|htm)'
        def get(path, ext)
          path = path + "." + ext
          @headers['Content-Type'] = Rack::Mime::MIME_TYPES[".\#{ext}"] || "text/plain"
          if path.include? ".." # prevent directory traversal attacks
            @status = "403"
            "403 - Invalid path"
          elsif !File.exists?("\#{PATH}/public/\#{path}")
            @status = "404"
            "404 - File not found"
          else
            @headers['X-Sendfile'] = "\#{PATH}/public/\#{path}"
            @headers['X-Accel-Redirect'] = "/\#{path}"
          end
        end
      end
    EOF
  end
end

class Class
  def parent_module
    name.split('::')[0..-2].join('::').constantize
  end

  def top_level_module
    name.split('::')[0].constantize
  end
end

module Enumerable
  def uniq_by
    seen = {}
    select { |v|
      key = yield(v)
      (seen[key]) ? nil : (seen[key] = true)
    }
  end
end

class Array
  def select!
    reject! { |v| not yield(v) }
  end
  def uniq_by!
    seen = {}
    select! { |v|
      key = yield(v)
      (seen[key]) ? nil : (seen[key] = true)
    }
  end
end


require 'rss'

module RSS
  class MakerProxy < Struct.new :maker
    def item options
      maker.items.new_item do |item|
        options.each { |key, value| item.send :"#{key}=", value }
      end
    end
  end

  def self.feed options
    image = options.delete(:image)
    Maker.make options.delete(:version) || '2.0' do |maker|
      options.each { |key, value| maker.channel.send :"#{key}=", value }
      maker.items.do_sort = true
      yield MakerProxy.new(maker)
    end
  end
end