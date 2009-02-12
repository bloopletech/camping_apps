require 'htmlentities/string'
require 'net/http'

Camping.goes :Feeds

module Feeds::Models
  class Feed < Base
  end

  class CreateFeeds < V 0.1
    def self.up
      create_table :feeds_feeds, :force => true do |t|
        t.column :url, :string
        t.column :position, :integer
      end
    end
  end
end

module Feeds::Controllers
  class Index < R '/'
    def get
      @feeds = Feed.find(:all) || []
      render :index
    end
  end

  class Proxy < R '/proxy/(.+)'
    def get(url)
      Net::HTTP.get(URI.parse("http://rss.bloople.net/?url=#{Camping.escape(url)}&limit=3&showempty=true&striphtml=true"))
    end
  end
  
  class Create < R '/create'
    def post
      oldlowest = Feed.find(:first, :order => 'position ASC')
      @feed = Feed.create(:url => @input.url, :position => oldlowest ? oldlowest.position - 1 : 0)
      
      redirect '/'
    end
  end

  class Remove < R '/remove/(.+)'
    def get(id)
      Feed.find(id.to_i).destroy
      redirect '/'
    end
  end
end

module Feeds::Views
  def layout
    xhtml_transitional do
      head do
        title "Feeds"
        style :type => "text/css" do
          %{
            /* <![CDATA[ */
            * { margin: 0; padding: 0; font: normal 100% "Lucida Grande", Helvetica, Arial, sans-serif; }
            body { background-color: #000000; color: #ffffff; padding: 1em 0.5em; }
            a { text-decoration: none; }
            #add { padding: 0 0.5em 1em 0.5em; }
            #add input { border: 1px solid #00ff00; padding: 1px solid #00ff00; width: 100%; color: #00ff00; background-color: #000000; }
            .column { width: 25%; float: left; }
            .feed { margin: 0 0.5em 1em 0.5em; padding: 0 0.5em 0.5em 0.5em; border: 1px solid #00ff00; }
            .feed .remove { float: right; }
            .feed h3.feed-title { font-weight: bold; background-color: #00ff00; padding: 0.2em 0.5em; margin: 0 -0.5em 0.5em -0.5em; }
            .feed h3.feed-title a { color: #000000; }
            .feed p.feed-item-desc { display: none; }

            .rss2html-note { display: none; }

            .clear { clear: both; }
            #footer { padding: 0 0.5em 0 0.5em; }
            /* ]]> */
          }
        end
        script :type => "text/javascript" do
          %{
            // <![CDATA[
            function x(id, http)
            {
              return (function() { if(http.readyState == 4) document.getElementById("feed-" + id).innerHTML = http.responseText });
            }

            window.onload = function()
            {
              for(var i = 0; i < feeds.length; i++)
              {
                var http = !!(window.attachEvent && !window.opera) ? new ActiveXObject("Microsoft.XMLHTTP") : new XMLHttpRequest();
                http.onreadystatechange = x(feeds[i].id, http);
                http.open("get", "/proxy/" + encodeURIComponent(feeds[i].url), true);
                http.send(null);
              };
            };
            // ]]>
          }
        end
      end
      body do
        self << yield
      end
    end
  end

  def index
    div.add! do
      form :action => '/create', :method => 'post' do
        input :type => 'text', :name => 'url', :value => 'http://'
      end
    end

    return if @feeds.empty?
    @feeds.each_slice((@feeds.length / 4.0).ceil) do |fs|
      div.column do
        fs.each do |f|
          div.feed do
            a 'X', :href => "/remove/#{f.id}", :class => "remove"
            div(:id => "feed-#{f.id}") { "Loading..." }
            div.clear { "" }
          end
        end
      end
    end

    script :type => "text/javascript" do
      "var feeds = #{@feeds.map { |f| { :url => f.url, :id => f.id } }.to_json};"
    end

    div.clear { "" }
    p.footer! { "#{File.stat(__FILE__).size} bytes of code." }
  end
end

def Feeds.create
  Feeds::Models.create_schema
  ActiveRecord::Base.default_timezone = :utc
end