#!/usr/bin/env rackup

#prerequisites:
# unix-style OS, ruby 1.8.6, rubygems 0.9+, camping 1.9+ (i.e. git), activerecord 2.0.2+, rack 0.3.0+
#to run:
# change establish_connection line to connect to your database, then run:
# rackup camping.ru
# ensure your VirtualHost files have <subdomain>.example.com pointing to localhost:9292/<subdomain>/ .

require '_configuration'

require 'camping'
require 'lib/markaby/lib/markaby'
require 'active_record'

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

Thread.new do
  while(true)
    sleep(300)
    GC.start
  end
end


Camping::Models::Base.establish_connection(DBCONN)
=begin
Camping::Models::Base.establish_connection(
:adapter => 'mysql',
:database => 'camping',
:username => 'root',
:password => '',
:host => 'localhost'
)
=end

Camping::Models.create_schema
Camping::Models::Session.create_schema if Camping::Models.const_defined?(:Session)

#ActiveRecord::Base.logger = Logger.new(STDOUT)

Dir.glob("*.rb").each do |file|
  title = File.basename(file)[/^([\w_]+)/,1].gsub /_/,''
  load file
  klass = Object.const_get(Object.constants.grep(/^#{title}$/i)[0]) rescue nil
  unless klass.nil?
    klass::Base.send(:include, TBIBase)
    klass.create if klass.respond_to? :create
    map("/#{title.downcase}") { run klass }
  end
end