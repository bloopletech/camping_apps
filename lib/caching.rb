module CampingCaching
  module Base
    def self.included(base)
      base.class_eval do
        def current_request_is_cacheable?
          self.class.cacheable && @env.REQUEST_METHOD.downcase == "get" && @env.QUERY_STRING == "" && @state.user_id.nil? &&
           (@state.flash.nil? || @state.flash == { :success => [], :errors => [] }) &&
           (@state.keys.map { |x| x.to_sym } - [:flash, :user_id]).empty?
        end

        alias_method :service_without_caching, :service
        def service(*a)
          puts "Camping blob: #{@state.inspect}"
          return service_without_caching(*a) unless current_request_is_cacheable?

          path = @env.PATH_INFO
          path = "/index" if path == '/' || path == ''
          path = "#{self.class.top_level_module::PATH}/public/cache/#{path.gsub(/^\//, '').gsub('/', '#')}"

          if File.exists?(path) && (Time.now - File.mtime(path)) < 600
            puts "Servicing request from cache"
            Marshal.load(File.read(path))
          else
            puts "Cache miss, generating response"

            o = service_without_caching(*a).to_a #changes this method to return array instead of controller instance
            o[2] = o[2].body.to_s #Ties us to ruby 1.8 and current camping implementation

            File.open(path, "w") { |f| f << Marshal.dump(o) }

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