require 'init/configuration'

require 'rubygems'

require 'mysqlplus'

class Mysql
  alias_method :query, :c_async_query
end

require 'active_record'
require 'lib/active_record_mysql_gone_patch'
 
require 'will_paginate'
require 'ostruct'
 
$:.unshift Pathname.new('./lib/camping/lib/').realpath
 
require 'camping'
require 'camping/server'
require 'lib/markaby/lib/markaby'

class Fixnum
  alias_method :xchr_old, :xchr  

  def xchr
    @@XChar_Cache ||= (0..255).map{|x| x.send :xchr_old} 
    @@XChar_Cache[self] or xchr_old 
  end
end

module TBIBase
  def self.included(base)
    base.class_eval <<-END
      def r404(p=env.PATH)
        r(404, "<h3>Oops! Page could not be found.</h3>")
      end
      def r500(k,m,x)
        puts $!
        puts $!.backtrace
        r(500, "<h3>Oops! An error occured; please try again.</h3>")
      end
      alias_method :initialize_without_rootfix, :initialize
      def initialize_with_rootfix(env)
        initialize_without_rootfix(env)
        @root = ''
      end
      alias_method :initialize, :initialize_with_rootfix
    END
  end
end

ActiveRecord::Base.default_timezone = :utc

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