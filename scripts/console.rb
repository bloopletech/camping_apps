#!/usr/bin/env ruby
# encoding: utf-8

require 'init/requires'

Camping::Models::Base.establish_connection(DBCONN)

Camping::Models.create_schema
Camping::Models::Session.create_schema if Camping::Models.const_defined?(:Session)

ActiveRecord::Base.logger = Logger.new(STDOUT)

(ARGV.empty? ? Dir.glob("*.rb") : ARGV).each do |file|
  title = File.basename(file)[/^([\w_]+)/,1].gsub /_/,''
  load file
  klass = Object.const_get(Object.constants.grep(/^#{title}$/i)[0]) rescue nil
  unless klass.nil?
    klass.create if klass.respond_to? :create
  end
end

silence_warnings { ARGV = [] }

require 'irb'
IRB.start(__FILE__)