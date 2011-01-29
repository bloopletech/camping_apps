# encoding: utf-8

require 'htmlentities/string'

Camping.goes :Crowdcount

module Crowdcount::Models
  class Count < Base
  end

  class CreateCrowdcount < V 0.1
    def self.up
      create_table :crowdcount_counts do |t|
        t.column :count, :integer
      end
      Count.create(:count => 0)
    end
  end

  class ChangeCrowdcountColumn < V 0.2
    def self.up
      change_column :crowdcount_counts, :count, :bigint
    end
  end
end

module Crowdcount::Controllers
  class Index < R '/'
    def get
      @count = Count.find(:first)
      render :index
    end
    
    def post
      case input.submit
      when '+'
        Count.find(:first).increment!(:count)
      when '-'
        Count.find(:first).decrement!(:count)
      end
      redirect '/'
    end
  end
end

module Crowdcount::Helpers
  def number_with_delimiter(number, delimiter=",", separator=".")
    begin
      parts = number.to_s.split('.')
      parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
      parts.join separator
    rescue
      number
    end
  end
end

module Crowdcount::Views
  def layout
    xhtml_transitional do
      head do
        title "Crowdcount"
        style :type => "text/css" do
          %{
            /* <![CDATA[ */
            * { margin: 0; padding: 0; font-family: "Lucida Grande", Helvetica, Arial, sans-serif; font-size: 100%; }
            body { background-color: #ffffff; color: #000000; padding: 1em; text-align: center; }
            h1 { font-size: 140%; margin-bottom: 0.2em; font-weight: bold; }
            input { margin: 0.25em; width: 2.5em; text-align: center; }
            p#count { font-size: 500%; }
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
    div do
      h1 { "crowdcount" }
      p.count! { number_with_delimiter @count.count }
      form :action => R(Index), :method => "post" do
        input :type => 'submit', :name => 'submit', :value => '+'
        input :type => 'submit', :name => 'submit', :value => '-'
      end
    end

    p.footer! { "Created by #{a "Brenton Fletcher", :href => "http://blog.bloople.net"} in #{File.stat(__FILE__).size} bytes of code." }
  end

end

def Crowdcount.create
  Crowdcount::Models.create_schema
  ActiveRecord::Base.default_timezone = :utc
end