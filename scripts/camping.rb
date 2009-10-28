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

conf = OpenStruct.new(:server => ARGV[0] || 'mongrel', :host => '0.0.0.0', :port => 8005, :database => { :adapter => 'mysql', :database => 'camping', :username => 'root', :password => '', :host => 'localhost', :pool => 50 })
paths = ["."]
                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                                 
server = Camping::Server::Base.new(conf, paths)
server.start