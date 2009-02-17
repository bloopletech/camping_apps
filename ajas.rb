# encoding: utf-8

$KCODE = 'u'

require 'camping/ar'
require 'camping/session'
require 'htmlentities/string'
require 'lib/common'

Camping.goes :Ajas

module Ajas
  PATH = File.expand_path(File.dirname(__FILE__)) + '/ajas'
  include Camping::Session
end

module Ajas::Models
  class Admin < Base
  end

  class CreateModels < V 0.5
    def self.up
      create_table :ajas_admins do |table|
        table.string :name, :password
      end
    end
  end
end

module Ajas::Controllers
  class AdminLogin < R '/admin/login', '/admin/logout'
    def post
      admin_login input.username, input.password
      admin_logged_in? ? redirect('/admin/blog') : get
    end
    def get
      admin_logout
      render :admin_login
    end
  end
  
  AdminLogout = AdminLogin

  class Index < R '/'
    def get
      @blog_posts = BlogPost.find(:all, :order => 'created_at DESC', :limit => 1)
      render :index
    end
  end

  include AssetsClass
end

module Ajas::Helpers
#  include ActionView::Helpers::
  def add_success(msg)
    @state[:flash] = { :success => [], :errors => [] } unless @state.key? :flash
    @state[:flash][:success] << msg
  end
  def add_error(msg)
    @state[:flash] = { :success => [], :errors => [] } unless @state.key? :flash
    @state[:flash][:errors] << msg
  end

  # login system
  def admin_current_user
    @current_user ||= Ajas::Models::Admin.find(@state.admin_id) unless @state.admin_id.blank?
  end
  alias admin_logged_in? admin_current_user
  
  def admin_login name, password
    @current_user = Ajas::Models::Admin.find_by_name_and_password input.name, input.password
    @state.admin_id = @current_user.id if @current_user
  end
  
  def admin_logout
    @state.admin_id = nil
  end

  # shortcut for error-aware labels
  def label_for name, record = nil, attr = name, options = {}
    errors = record && !record.body.blank? && !record.valid? && record.errors.on(attr)
    label name.to_s.humanize, { :for => name }, options.merge(errors ? { :class => :error } : {})
  end

  def nice_date_time(date)
    return date.strftime("%d/%m/%Y %I:%M%p")
  end

  def nice_date(date)
    return date.strftime("%d/%m/%Y")
  end

  def h(text)
    CGI::escapeHTML(text)
  end
end

module Ajas::Views
  def layout
    content = yield
    @content_for ||= {}

    if @render_layout.nil?
      @render_layout = true
    end

    if @render_layout
      
      xhtml_transitional do
        head do
          title { "AJAS: Adelaide Japanese Animation Society" }
          link :href => '/style.css', :rel => 'stylesheet', :type => 'text/css'
          self << @content_for[:head]
        end
        body do
          div.wrapper! do
            div.header! do
              h1 { a("AJAS: Adelaide Japanese Animation Society", :href => '/') }
            end
            div.main! do
              div.header_image_wrap! do
                p.nav! { [a('Home', :href => '/'), a('Forum', :href => 'http://ajas.org.au/forum/'), a('Where to find us', :href => '/blog/1/')].join(' | ') }
                if defined?(@anime_title) and @anime_title.has_banner?
                  img(:src => @anime_title.banner_large_url)
                else
                  t = Ajas::Models::AnimeTitle.random_with_image
                  a(:href => "/anime/#{t.id}", :id => 'header_image_link') { img(:src => t.banner_large_url) }
                end
              end

              @state[:flash] = { :success => [], :errors => [] } unless @state.key? :flash
              unless @state[:flash][:success].empty?
                div.success! do
                  ul { @state[:flash][:success].each { |s| li { h s } } }
                end
              end
              @state[:flash][:success] = []

              unless @state[:flash][:errors].empty?
                div.errors! do
                  p { "There were some errors:" }
                  ul { @state[:flash][:errors].each { |s| li { h s } } }
                end
              end
              @state[:flash][:errors] = []


              if admin_logged_in?
                p { [a('Blog', :href => '/admin/blog'), a('Anime', :href => '/admin/anime'), a("Pages", :href => '/admin/pages'),
                      a('Logout', :href => '/admin/logout')].join(" | ") }
              end
              self << content
            end
            div.footer! do
              p { "This is a temporary design." }
            end
          end
        end
      end
    else
      self << content
    end
  end

  def admin_login
    _login_form
  end

  def _login_form
    form :action => '/admin/login', :method => :post do
      div do
        label_for :name
        input :name => :name, :type => :text
      end
      div do
        label_for :password
        input :name => :password, :type => :password
      end
      div do
        input :type => :submit, :class => "submit", :name => :login, :value => 'Login'
      end
    end
  end

  def index
    div.column1! do
      div.inner do
        h2 { "Blog" }
        blog_list_posts
        p { a('More...', :href => '/blog/archive/1') } unless Ajas::Models::BlogPost.count(:all) <= 1
      end
    end
    div.column2! do
      div.inner do
        h2 { "What's next" }
        text Ajas::Models::Page.find(2).body
      end
    end
    div.column3! do
      div.inner do
        h2 { "Welcome to AJAS" }
        text Ajas::Models::Page.find(1).body
      end
    end
    div.clear { "" }
  end
end

require 'ajas/blog'
require 'ajas/pages'
require 'ajas/anime'
require 'ajas/whats_next'
require 'ajas/home_page_content'

def Ajas.create
  Ajas::Models.create_schema
  ActiveRecord::Base.default_timezone = :utc
end