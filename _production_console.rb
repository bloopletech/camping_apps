require '_configuration'

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

Camping::Models::Base.establish_connection(DBCONN)

Camping::Models.create_schema
Camping::Models::Session.create_schema if Camping::Models.const_defined?(:Session)

ActiveRecord::Base.logger = Logger.new(STDOUT)

Dir.glob("*.rb").each do |file|
  next if file[0, 1] == '_'
  title = File.basename(file)[/^([\w_]+)/,1].gsub /_/,''
  load file
  klass = Object.const_get(Object.constants.grep(/^#{title}$/i)[0]) rescue nil
  unless klass.nil?
    klass.create if klass.respond_to? :create
  end
end

require 'irb'
IRB.start(__FILE__)