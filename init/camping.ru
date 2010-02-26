#!/usr/bin/env rackup
#$DEBUG = 1
#require 'profile'
#prerequisites:
# unix-style OS, ruby 1.8.6, rubygems 0.9+, camping 1.9+ (i.e. git), activerecord 2.0.2+, rack 0.3.0+
#to run:
# change establish_connection line to connect to your database, then run:
# rackup camping.ru
# ensure your VirtualHost files have <subdomain>.example.com pointing to localhost:9292/<subdomain>/ .

Dir.chdir(File.dirname(__FILE__) + '/..')
STDERR.reopen "log/errors.log", "a"

require 'init/requires'

#Yeahhh... this is not exactly optimal
Thread.new do
  while(true)
    sleep(300)
    GC.start
  end
end

Camping::Models::Base.establish_connection(DBCONN)
 
Camping::Models.create_schema
Camping::Models::Session.create_schema if Camping::Models.const_defined?(:Session)
 
ActiveRecord::Base.logger = Logger.new(STDOUT) if ENV['CAMPING_ENV'] =~ /^d/

dirs = Dir.glob("*.rb")

PRIVATE_CAMPING_DIR = "/home/bloople/www/private_camping/current"
dirs += Dir.glob("#{PRIVATE_CAMPING_DIR}/*.rb") if File.directory?(PRIVATE_CAMPING_DIR)

dirs.each do |file|
  title = File.basename(file)[/^([\w_]+)/,1].gsub /_/,''
  Dir.chdir(File.dirname(file)) { load file }
  klass = Object.const_get(Object.constants.grep(/^#{title}$/i)[0]) rescue nil
  unless klass.nil?
    klass.send(:include, CampingCallPatches)
    klass::Base.send(:include, CampingBasePatches)

    klass.send(:include, CampingCaching)

    klass.create if klass.respond_to? :create
    map("/#{title.downcase}") { run klass }
  end
end