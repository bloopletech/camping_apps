# encoding: utf-8

require 'camping/session'
require 'htmlentities/string'
require 'rails_generator/secret_key_generator'
require 'net/http'
require 'ezcrypto'

Camping.goes :Reauthrss

module Reauthrss
  include Camping::Session
end

module Reauthrss::Models
  class Account < Base
    @@key = EzCrypto::Key.with_password EZCRYPTO1, EZCRYPTO2

    def feed(url)
      uri = URI.parse(url)
      Net::HTTP.start(uri.host, uri.port) do |http|
        req = Net::HTTP::Get.new(uri.path)
        req.basic_auth username, password
        return http.request(req).body
      end
    end

    def password
      @@key.decrypt self[:password]
    end

    def password=(password)
      self[:password] = @@key.encrypt password
    end

    def self.encrypt_password(password)
      @@key.encrypt password
    end
  end

  class CreateAccounts < V 1
    def self.up
      create_table :reauthrss_accounts, :force => true do |t|
        t.column :username, :string
        t.column :password, :binary
        t.column :public_id, :string
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
      end
    end
  end

  class MakeAccountPublicIdsUnique < V 2
    def self.up
      add_index :reauthrss_accounts, :public_id, :unique => true
    end
  end
end

module Reauthrss::Controllers
  class Index < R '/'
    def get
      if logged_in?
        render :logged_in
      else
        render :index
      end
    end
    
    def post
      login input.username, input.password
      unless logged_in?
        Account.create(:username => input.username, :password => input.password, :public_id => Rails::SecretKeyGenerator.new(ENV['ID']).generate_secret[0..20])
        login input.username, input.password
      end

      add_success("Logged in!")
      redirect '/'
    end
  end

  class Logout < R '/logout'
    def get
      add_success("Logged out.")
      logout
      redirect '/'
    end
  end

  class ChangePassword < R '/change_password'
    def post
      current_user.update_attributes(:password => input.password)
      current_user.save!
      add_success("Password changed.")
      redirect '/'
    end
  end

  class DeleteAccount < R '/delete_account'
    def post
      current_user.destroy
      add_success("Account deleted.")
      logout
      redirect '/'
    end
  end

  class Feed < R '/(.+?)/(.+)'
    def get(id, url)
      @env['REQUEST_URI'] =~ /^\/(?:reauthrss\/|)([a-z0-9]*?)\/(.*)$/
      Account.find_by_public_id($1).feed($2)
    end
  end

  class Style < R '/style.css'
    def get
      @headers["Content-Type"] = "text/css; charset=utf-8"
      @body = %{
        * { margin: 0; padding: 0; font-family: Georgia, "Times New Roman", serif; font-size: 100%; }
        body { background-color: #ffffff; color: #000000; padding: 1em; }
        h1 { font-size: 200%; margin: 0 0; font-weight: bold; }
        h1 a { color: #000000; text-decoration: none; }
        h2 { font-size: 140%; margin: 0.8em 0 0.5em 0; font-weight: bold; }
        h3 { margin: 0.8em 0; font-weight: bold; }
        p { margin: 0 0 1em 0; }
        ul, ol { margin: 1em 0 0.5em 1.5em; }
        li { margin-bottom: 0.5em; }
        label { width: 8em; display: block; float: left; text-align: right; padding: 0.2em 0.3em 0 0; }
        input { width: 20em; }
        input.submit { margin-left: 8.3em; width: 8em; }
        form div { clear: left; margin: 0.5em; }
        
        #header { padding-bottom: 0.5em; border-bottom: 1px solid #a0a0a0; margin-bottom: 1em; position: relative; height: 3em; }
        #nav { float: right; }
        
        #success { background-color: #008000; border: 1px solid #00ff00; padding: 0.5em; color: #ffffff; margin-bottom: 1em; }
        #success ul, #errors ul { list-style-type: none; margin: 0; }
        
        #errors { background-color: #a00000; border: 1px solid #ff0000; padding: 0.5em; color: #ffffff; margin-bottom: 1em; }

        #footer { margin: 1em 0 0 0; padding-top: 1em; border-top: 1px solid #a0a0a0; }
        
        .column { margin-right: 1em; float: left; width: 33%; }
        .clear { clear: both; }
      }
    end
  end
end
module Reauthrss::Helpers
  def add_success(msg)
    @state[:flash] = { :success => [], :errors => [] } unless @state.key? :flash
    @state[:flash][:success] << msg
  end
  def add_error(msg)
    @state[:flash] = { :success => [], :errors => [] } unless @state.key? :flash
    @state[:flash][:errors] << msg
  end

  def label_for name, record = nil, attr = name, options = {}
    errors = record && !record.valid? && record.errors.on(attr)
    label name.to_s.humanize, { :for => name }, options.merge(errors ? { :class => :error } : {})
  end



  # login system
  def current_user
    @current_user ||= Reauthrss::Models::Account.find(@state.user_id) unless @state.user_id.blank?
  end
  alias logged_in? current_user
  
  def login name, password
    @current_user = Reauthrss::Models::Account.find_by_username_and_password name, Reauthrss::Models::Account.encrypt_password(password)
    @state.user_id = @current_user.id if @current_user
  end
  
  def logout
    @state.user_id = nil
  end

  def ensure_logged_in
    unless logged_in?
      add_error("You must be logged in to do that.")
      redirect '/'
    end
    logged_in?
  end

  def nice_date_time(date)
    return date.strftime("%d/%m/%Y %I:%M%p")
  end

  def h(text)
    CGI::escapeHTML(text)
  end
end

module Reauthrss::Views
  def layout
    xhtml_transitional do
      head do
        title "reauthrss"
        link :rel => 'stylesheet', :type => 'text/css', :href => '/style.css', :media => 'screen'
      end
      body do
        div.header! do
          if logged_in?
            div.nav! { a('Logout', :href => '/logout') }
          end
          h1 { a("reauthrss", :href => '/') }
        end
        div.main! do
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

          self << yield
        end
        p.footer! { "Created by #{a "Brenton Fletcher", :href => "http://i.bloople.net"} in #{File.stat(__FILE__).size} bytes of code. <a href='mailto:&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;'>Email me</a>! Made on a #{a "Mac", :href => "http://apple.com"}. Powered by #{a "Ruby", :href => "http://ruby-lang.org"} on #{a "Camping", :href => "http://code.whytheluckystiff.net/camping/"}." }
      end
    end
  end

  def index
    h2 { "What's all this then?" }
    p { "Ever tried to subscribe to your <a href='http://twitter.com'>twitter</a> RSS feed in a web-based feed reader like <a href='http://reader.google.com'>Google Reader</a>? It doesn't work, because twitter requires you to enter your username and password to view the RSS feed, and web-based feed readers don't support this." }
    p { "Well this website fixes that. By entering your twitter username and password below, you can generate an RSS feed that will work in web-based feed readers. It's really that easy." }
    p { "For the technical types: this service isn't restriced to twitter or RSS feeds; you can use it anytime you need to re-publish content that's protected by HTTP Basic Authentication." }
    h2 { "Log in" }
    p { strong { "Note that your twitter password will be stored on my server; you can delete your password from this system at anytime - just log in below and click 'Delete account'." } }
    form :action => '/', :method => "post" do
      div do
        label_for :username
        input.username :name => "username"
      end
      div do
        label_for :password
        input.password :name => "password", :type => 'password'
      end
      div do
        input.submit :type => 'submit', :value => 'Login'
      end
    end
  end

  def logged_in
    h2 { "Logged in as #{h current_user.username}" }
    ol do
      li { "Click the 'Add subscription' link/button in your feed reader." }
      li { "Copy the following URL and paste it into the textbox in the feed reader:&nbsp;&nbsp;http://r.bloople.net/#{current_user.public_id}/" }
      li { "Get the URL of your twitter feed (click the RSS link at the bottom of your twitter page and copy that URL) and put it in the textbox in the feed reader, after the URL from step 2.<br />Example: http://r.bloople.net/#{current_user.public_id}/http://twitter.com/statuses/friends_timeline/15440326.rss" }
      li { "Click the 'Add' button to finish adding the subscription. You're done!" }
    end
    h3 { "Change password" }
    p { "Use the form below to change your password:" }
    form :action => '/change_password', :method => "post" do
      div do
        label_for :new_password
        input.password :name => "password", :type => 'password'
      end
      div do
        input.submit :type => 'submit', :value => 'Change'
      end
    end
    h3 { "Delete account" }
    p { "You can delete your username and password from this site by clicking below. This does not delete your Twitter account. Note that your RSS feeds won't load through this site anymore." }
    form :action => '/delete_account', :method => "post" do
      input.submit :type => 'submit', :value => 'Delete account'
    end
  end
end

def Reauthrss.create
  Reauthrss::Models.create_schema
  ActiveRecord::Base.default_timezone = :utc
end