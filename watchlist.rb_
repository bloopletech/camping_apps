# encoding: utf-8

require 'camping/session'
require 'htmlentities/string'
require 'lib/common'

require 'will_paginate'
require 'will_paginate/view_helpers'

class String
  def escape_once
    gsub(/[\"><]|&(?!([a-zA-Z]+|(#\d+));)/) { |special| ERB::Util::HTML_ESCAPE[special] }
  end
end

WillPaginate.enable_activerecord

module WillPaginate
  class LinkRenderer
    def to_html
      puts "template: #{@template.inspect}"
      links = @options[:page_links] ? windowed_links : []
      # previous/next buttons
      links.unshift page_link_or_span(@collection.previous_page, %w(disabled prev_page), @options[:prev_label])
      links.push    page_link_or_span(@collection.next_page,     %w(disabled next_page), @options[:next_label])
  
      html = links.join(@options[:separator])
      @options[:container] ? "<div #{html_attributes.each_pair { |k, v| "#{k}='#{v.escape_once}" }.join(' ')}>#{html.escape_once}</div>" : html
    end

    def page_link_or_span(page, span_class, text = nil)
      text ||= page.to_s
      classnames = Array[*span_class]
      
      if page and page != current_page
        "<a href='#{url_for(page).escape_once}' rel='#{rel_value(page).escape_once}' class='#{classnames[1].escape_once}>#{text}</a>"
      else
        "<span class='#{classnames.join(' ').escape_once}'>#{text.escape_once}</span>"
      end
    end

    # Returns URL params for +page_link_or_span+, taking the current GET params
    # and <tt>:params</tt> option into account.
    def url_for(page)
      puts self.class.ancestors.inspect
      unless @url_string
        @url_params = { :escape => false }
        # page links should preserve GET parameters
        stringified_merge @url_params, @template.input if @template.instance_variable_get("@request").env['REQUEST_METHOD'] == 'get' #LOL WUT
        stringified_merge @url_params, @options[:params] if @options[:params]
        
        if param_name.index(/[^\w-]/)
          page_param = (defined?(CGIMethods) ? CGIMethods : ActionController::AbstractRequest).
            parse_query_parameters("#{param_name}=#{page}")
          
          stringified_merge @url_params, page_param
        else
          @url_params[param_name] = page
        end
puts "url params: #{@url_params.inspect}"
        url = @template.url_for(@url_params)
        @url_string = url.sub(%r!([?&/]#{CGI.escape param_name}[=/])#{page}!, '\1@')
        return url
      end
      @url_string.sub '@', page.to_s
    end
  end
end

Camping.goes :Watchlist

module Watchlist
  include Camping::Session
  PATH = File.expand_path(File.dirname(__FILE__)) + '/watchlist'
end

require 'watchlist/models'
require 'watchlist/controllers'
require 'watchlist/helpers'
require 'watchlist/views'

def Watchlist.create
  Watchlist::Models.create_schema
  ActiveRecord::Base.default_timezone = :utc
end