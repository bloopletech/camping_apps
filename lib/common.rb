module AssetsClass
  def self.included(base)
    base.class_eval <<-EOF
      class Assets < R '/(.+)\\\.(css|gif|js|jpg|png|zip|txt|ico|swf|flv)'
        MIME_TYPES = { '.css' => 'text/css', '.gif' => 'image/gif', '.js' => 'text/javascript', '.jpg' => 'image/jpeg', '.zip' => 'application/zip', '.txt' => 'text/plain', '.ico' => 'image/vnd.microsoft.icon', '.png' => 'image/png', '.swf' => 'application/x-shockwave-flash', '.flv' => 'application/octet-stream' }

        def get(path, ext)
          path = path + "." + ext
          @headers['Content-Type'] = MIME_TYPES[path[/\.\\\w+$/, 0]] || "text/plain"
          unless path.include? ".." # prevent directory traversal attacks
            @headers['X-Sendfile'] = "\#{PATH}/public/\#{path}"
            @headers['X-Accel-Redirect'] = "/\#{path}"
          else
            @status = "403"
            "403 - Invalid path"
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