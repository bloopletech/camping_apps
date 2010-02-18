module CampingCaching
  module Base
    def self.included(base)
      base.class_eval do
        alias_method :service_without_caching, :service
        def service(*a)
          return service_without_caching(*a) unless self.class.cacheable && @env.REQUEST_METHOD.downcase == "get" && @env.QUERY_STRING == ""

          path = @env.PATH_INFO
          path = "/index" if path == '/' || path == ''
          path = "#{self.class.top_level_module::PATH}/public/cache/#{path.gsub(/^\//, '').gsub('/', '#')}"

          if File.exists?(path) && (Time.now - File.mtime(path)) < 600
            puts "Servicing request from cache"

            [200, Marshal.load(File.read("#{path}.headers")), File.new(path, "r")]
          else
            puts "Cache miss, generating response"

            o = service_without_caching(*a).to_a #changes this method to return array instead of controller instance

            str = ""
            o[2].each { |line| str << line }

            File.open("#{path}.headers", "w") { |f| f << Marshal.dump(o[1]) }
            File.open(path, "w") { |f| f << str }

            o
          end
        end
      end
    end
  end

  module Controller
    def self.included(base)
      class << base
        attr_accessor :cacheable
      end
    end
  end

  def self.included(klass)
    klass::Base.send(:include, CampingCaching::Base)
    klass::Controllers.constants.each { |c| klass::Controllers.const_get(c).send(:include, CampingCaching::Controller) }
  end
end