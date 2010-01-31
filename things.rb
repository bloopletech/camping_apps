# encoding: utf-8

require 'htmlentities/string'

Camping.goes :Things

module Things::Models
  class Thing < Base
    def state
      self[:state] ? 'awesome' : 'fail'
    end
  end

  class CreateThings < V 0.1
    def self.up
      create_table :things_things, :force => true do |t|
        t.column :name, :string
        t.column :state, :boolean
        t.column :published, :datetime
      end
    end
  end
end

module Things::Controllers
  class Index < R '/'
    def get
      @awesome_things = Thing.find_all_by_state(true, :order => 'published DESC', :limit => 500) || []
      @fail_things = Thing.find_all_by_state(false, :order => 'published DESC', :limit => 500) || []
      render :index
    end
    
    def post
      @thing = Thing.create(:name => input.name[0..50], :state => input.state, :published => DateTime.now)
      redirect '/'
    end
  end
end

module Things::Views
  def layout
    xhtml_transitional do
      head do
        title "Things"
        style :type => "text/css" do
          %{
            /* <![CDATA[ */
            * { margin: 0; padding: 0; font-family: "Lucida Grande", Helvetica, Arial, sans-serif; font-size: 100%; }
            body { background-color: #ffffff; color: #000000; padding: 1em 0; }
            #awesome, #fail { float: left; width: 50%; }
            #awesome div, #fail div { margin: 0 1em; padding-bottom: 0.5em; }
            #awesome div { padding-right: 1em; border-right: 1px solid #a0a0a0; margin-right: 0; }
            #awesome p, #fail p { padding-top: 0.3em; border-top: 1px solid #a0a0a0; margin-top: 0.3em; margin-bottom: 0.3em; }
            #awesome p.last, #fail p.last { margin-bottom: 0; padding-bottom: 0.3em; border-bottom: 1px solid #a0a0a0; }
            h2 { font-size: 140%; margin-bottom: 0.2em; font-weight: bold; }
            input.name { width: 99%; }
            .clear { clear: both; }
            #footer { margin: 1em; }
            /* ]]> */
          }
        end
      end
      body do
        self << yield
      end
    end
  end

  def index
    div.awesome! do
      div do
        h2 { "things that are awesome" }
        form :action => R(Index), :method => "post" do
          input.name :name => "name"
          input :type => 'hidden', :name => 'state', :value => 'true'
        end
        @awesome_things.each do |thing|
          ph = {}
          ph[:class] = 'last' if thing == @awesome_things.last
          p(ph) { thing.name }
        end
      end
    end
    div.fail! do
      div do
        h2 { "things that are fail" }
        form :action => R(Index), :method => "post" do
          input.name :name => "name"
          input :type => 'hidden', :name => 'state', :value => 'false'
        end
        @fail_things.each do |thing|
          ph = {}
          ph[:class] = 'last' if thing == @fail_things.last
          p(ph) { thing.name.encode_entities }
        end
      end
    end

    div.clear { "" }
    p.footer! { "Created by #{a "Brenton Fletcher", :href => "http://blog.bloople.net"} in #{File.stat(__FILE__).size} bytes of code. " +
     "<a href='mailto:&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;'>Email me</a>! Powered by " +
     "#{a "Ruby", :href => "http://ruby-lang.org"} on #{a "Camping", :href => "http://github.com/camping/camping/"}." }
  end

end

def Things.create
  Things::Models.create_schema
  ActiveRecord::Base.default_timezone = :utc
end