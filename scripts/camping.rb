#!/usr/bin/ruby
# encoding: utf-8

#ENV['INLINEDIR'] = '/Users/bloopletech/ruby-1.9/'

require 'logger'
$logger = Logger.new('log.txt')

class String
  alias_method :each, :each_line
end

require 'init/requires'

ActiveRecord::Base.logger = Logger.new(STDOUT)

Camping::Models::Base.establish_connection(DBCONN)

Camping::Models.create_schema
Camping::Models::Session.create_schema if Camping::Models.const_defined?(:Session)

conf = OpenStruct.new(:server => 'mongrel', :host => '0.0.0.0', :port => 8005, :database => { :adapter => 'mysql', :database => 'camping', :username => 'root', :password => '', :host => 'localhost', :pool => 50 })
paths = ARGV.empty? ? ["."] : ARGV
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
server = Camping::Server::Base.new(conf, paths)
server.start