#!/usr/bin/env rackup

require 'camping'


module TBIBase
  def self.included(base)
    base.class_eval <<-END
      def r404(p=env.PATH)
        r(404, "<h3>Oops! Page could not be found.</h3>")
      end
      def r500(k,m,x)
        r(500, "<h3>Oops! An error occured; please try again.</h3>")
      end
    END
  end
end

Camping::Models::Base.establish_connection({:adapter => 'sqlite3', :database => '.camping.db'})

Camping::Models::Session.create_schema if Camping::Models.const_defined?(:Session)

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