#!/usr/bin/ruby
# encoding: utf-8

require '_configuration'

#ENV['INLINEDIR'] = '/Users/bloopletech/ruby-1.9/'

require 'logger'
$logger = Logger.new('log.txt')

class String
  alias_method :each, :each_line
end

class LoggedArray
  def initialize
    @arr = []
  end

  def inspect
    @arr.inspect
  end

  def method_missing(name, *args, &block)
    puts "In a LoggedArray \##{@arr.__id__}, calling method #{name} with #{args.inspect}, block_given? #{block_given?}"
    @arr.send(name, *args, &block)
  end
end

if $0 == __FILE__
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

  ActiveRecord::Base.logger = Logger.new(STDOUT)

  ActiveRecord::Base.default_timezone = :utc

  conf = OpenStruct.new(:server => ARGV[0] || 'mongrel', :host => '0.0.0.0', :port => 8005, :database => { :adapter => 'mysql', :database => 'camping', :username => 'root', :password => '', :host => 'localhost', :pool => 50 })
  paths = ["."]
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                   
  server = Camping::Server::Base.new(conf, paths)
  server.start
end
