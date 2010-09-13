ENVIRONMENT = (!ENV.key?("CAMPING_ENV") || ENV["CAMPING_ENV"] == "development") ? "development" : "production"

require 'init/configuration'

require 'rubygems'

#gem 'hpricot', '0.8.2'
gem 'hpricot', '0.6'
gem 'activesupport', '2.3.8'
gem 'activerecord', '2.3.8'
gem 'actionpack', '2.3.8'
gem 'rails', '2.3.8'

require 'active_record'

require 'will_paginate'
require 'ostruct'

#require 'pathname' 

#Camping + markaby 
$:.unshift Pathname.new('./lib/camping/lib/').realpath
 
require 'camping'
require 'camping/server'
require 'lib/markaby/lib/markaby'
#end

require 'lib/caching'

class Fixnum
  alias_method :xchr_old, :xchr  

  def xchr
    @@XChar_Cache ||= (0..255).map{|x| x.send :xchr_old} 
    @@XChar_Cache[self] or xchr_old 
  end
end

#use Rack::MailExceptions, MAIL_EXCEPTIONS_CONFIG

module CampingBasePatches
  def self.included(base)
    base.class_eval do
      def r404(p=env.PATH)
        r(404, "<h3>Oops! Page could not be found.</h3>")
      end
      def r500(k,m,x)
#        puts $!
#        puts $!.backtrace
        r(500, "<h3>Oops! An error occured; please try again.</h3>")
      end
      alias_method :initialize_without_rootfix, :initialize
      def initialize_with_rootfix(env)
        initialize_without_rootfix(env)
        @root = ''
      end
      alias_method :initialize, :initialize_with_rootfix
    end
  end
end

module CampingCallPatches
  def self.included(base)
    base.class_eval do
      class << self
        alias_method :call_without_patches, :call
        def call(e)
          begin
#            Camping::Models::Base.connection_pool.clear_stale_cached_connections!
            z = Time.now

            o = call_without_patches(e)

            puts "time to serve #{e.to_hash['PATH_INFO']}: #{Time.now - z}"
          ensure
            Camping::Models::Base.clear_active_connections!
          end
          o
        end
      end
    end
  end
end
  
Time.zone_default = ActiveSupport::TimeZone["Adelaide"] #TODO best way to grab adelaide timezone?
ActiveRecord::Base.default_timezone = :utc
ActiveRecord::Base.time_zone_aware_attributes = true

ActiveSupport::CoreExtensions::Time::Conversions::DATE_FORMATS.merge!(:default => '%d %B %Y') #TODO fix so shows time as well
ActiveSupport::CoreExtensions::Date::Conversions::DATE_FORMATS.merge!(:default => '%d %B %Y')

=begin
module Camping
  module Base
    def call(e)
      begin
        Camping::Models::Base.connection_pool.clear_stale_cached_connections!
        Time.zone = TIME_ZONE
        z = Time.now

        o = super

        puts "time to serve #{e.PATH_INFO}: #{Time.now - z}"
      ensure
        Camping::Models::Base.connection_pool.release_connection
      end
      o
    end
  end
end
=end

=begin
Alt of above
module Camping
  class << self
    alias_method :goes_without_hacks, :goes
    def goes_with_hacks(sym)
      goes_without_hacks(sym)
      Apps.last.instance_eval <<-END2
        def r404(p=env.PATH)
          r(404, "<h3>Oops! Page could not be found.</h3>")
        end
        def r500(k,m,x)
          r(500, "<h3>Oops! An error occured; please try again.</h3>")
        end
      END2
      Apps.last.instance_eval "@root = ''"
    end
    alias_method :goes, :goes_with_hacks
  end
end
=end