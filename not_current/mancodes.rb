require 'camping/session'
require 'htmlentities/string'

Camping.goes :Mancodes

module Mancodes
  include Camping::Session
end

module Mancodes::Models
  class Mancode < Base
    validates_presence_of :name, :action, :meaning
    belongs_to :user
    has_many :comments, :order => 'created_at ASC'
    def score
      ((positive_votes || 0) - (negative_votes || 0)) / 2
    end
  end
  
  class Comment < Base
    belongs_to :mancode
    belongs_to :user
    validates_presence_of :body
  end

  class User < Base
    validates_uniqueness_of :name
    has_many :mancodes
    has_many :comments
  end

  class CreateMancodes < V 0.1
    def self.up
      create_table :mancodes_mancodes, :force => true do |t|
        t.column :user_id, :integer
        t.column :name, :string
        t.column :action, :text
        t.column :meaning, :text
        t.column :positive_votes, :integer
        t.column :negative_votes, :integer
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
      end
      create_table :mancodes_comments, :force => true do |t|
        t.column :user_id, :integer
        t.column :mancode_id, :integer
        t.column :body, :string
        t.column :created_at, :datetime
        t.column :updated_at, :datetime
      end
      create_table :mancodes_users, :force => true do |table|
        table.string :name, :password, :email
      end
    end
  end
end

module Mancodes::Controllers
  class Index < R '/'
    def get
      @popular_mancodes = Mancode.find(:all, :order => 'positive_votes DESC', :limit => 10) || []
      @new_mancodes = Mancode.find(:all, :order => 'created_at DESC', :limit => 10) || []
      render :index
    end
  end

  class Popular < R '/popular'
    def get
      @mancodes = Mancode.find(:all, :order => 'positive_votes DESC', :limit => 250) || []
      render :popular
    end
  end

  class Newest < R '/newest'
    def get
      @mancodes = Mancode.find(:all, :order => 'created_at DESC', :limit => 250) || []
      render :newest
    end
  end

  class Create
    def get
      return unless ensure_logged_in
      @mancode = Mancode.new
      render :create
    end

    def post
      return unless ensure_logged_in
      @mancode = Mancode.new(:name => input.name, :action => input.action, :meaning => input.meaning, :user => current_user)
      if @mancode.save
        add_success("Mancode created")
        redirect "/#{@mancode.id}"
      else
        @mancode.errors.full_messages.each { |msg| add_error(msg) }
        render :create
      end
    end
  end

  class Update < R '/(\d+)/update'
    def get(id)
      return unless ensure_logged_in
      @mancode = Mancode.find_by_id_and_user_id(id.to_i, current_user.id)
      render :update
    end

    def post(id)
      return unless ensure_logged_in
      @mancode = Mancode.find_by_id_and_user_id(id.to_i, current_user.id)
      if @mancode.update_attributes(:name => input.name, :action => input.action, :meaning => input.meaning)
        add_success("Mancode updated")
        redirect "/#{@mancode.id}"
      else
        @mancode.errors.full_messages.each { |msg| add_error(msg) }
        render :update
      end
    end
  end

  class Destroy < R '/(\d+)/destroy'
    def get(id)
      return unless ensure_logged_in
      @mancode = Mancode.find_by_id_and_user_id(id.to_i, current_user.id).destroy
      add_success("Mancode deleted")
      redirect '/'
    end
  end

  class Login < R '/login', '/logout'
    def post
      login input.username, input.password
      if logged_in?
        add_success("Logged in!")
        redirect(Index)
      else
        add_error("Your username or password was incorrect.")
        get
      end
    end
    def get
      logout
      render :login
    end
  end
  
  Logout = Login

  class Signup
    def get
      @user = User.new
      render :signup
    end
    
    def post
      @user = User.new(:name => input.name, :password => input.password, :email => input.email)
      if @user.save
        add_success("User created")
        redirect '/login'
      else
        @user.errors.full_messages.each { |msg| add_error(msg) }
        render :signup
      end
    end
  end

  class Show < R '/(\d+)'
    def get(id)
      @mancode = Mancode.find(id.to_i)
      @comment = Comment.new
      render :show
    end

    def post(id)
      return unless ensure_logged_in
      @mancode = Mancode.find(id.to_i)
      @comment = Comment.new(:mancode => @mancode, :user_id => current_user.id, :body => input.body)
      if @comment.save
        add_success("Comment posted")
        redirect "/#{id}"
      else
        @comment.errors.full_messages.each { |msg| add_error(msg) }
        render :show
      end
    end
  end
  
  class VoteUp < R '/(\d+)/up'
    def get(id)
      return unless ensure_logged_in
      @mancode = Mancode.find(id.to_i)
      @mancode.increment!(:positive_votes)
      redirect R(Show, @mancode)
    end
  end

  class VoteDown < R '/(\d+)/down'
    def get(id)
      return unless ensure_logged_in
      @mancode = Mancode.find(id.to_i)
      @mancode.increment!(:negative_votes)
      redirect R(Show, @mancode)
    end
  end

  class Style < R '/style.css'
    def get
      @headers["Content-Type"] = "text/css; charset=utf-8"
      @body = %{
        * { margin: 0; padding: 0; font-family: "Georgia", "Times New Roman", serif; font-size: 100%; }
        body { background-color: #ffffff; color: #000000; padding: 1em; }
        h1 { font-size: 200%; margin: 0 0; font-weight: bold; }
        h1 a { color: #000000; text-decoration: none; }
        h2 { font-size: 140%; margin: 0.8em 0; font-weight: bold; }
        h3 { font-size: 110%; margin: 1.1em 0 0.6em 0; font-weight: bold; }
        h4 { margin: 1em 0; font-weight: bold; }
        p { margin: 0 0 1em 0; }
        
        ul { margin: 1em 0 1em 1.5em; }
        
        label { width: 5em; display: block; float: left; text-align: right; padding: 0.2em 0.3em 0 0; }
        input, textarea { width: 20em; }
        input.submit { margin-left: 5.3em; width: 8em; }
        form div { clear: left; margin: 0.5em; }
        
        #header { padding-bottom: 0.5em; border-bottom: 1px solid #a0a0a0; margin-bottom: 1em; position: relative; height: 3em; }
        #user_nav { float: right; }
        #nav { position: absolute; bottom: 0.35em; right: 0; }
        #nav ul { list-style-type: none; margin: 0; }
        #nav ul li { list-style-type: none; display: inline; margin: 0 0.25em; }
        #nav ul li a { padding: 0.35em 0.35em 0.35em 0.35em; background-color: #008000; color: #ffffff; text-decoration: none; }
        
        #success { background-color: #008000; border: 1px solid #00ff00; padding: 0.5em; color: #ffffff; margin-bottom: 1em; }
        #success ul { list-style-type: none; margin: 0; }
        
        #errors { background-color: #a00000; border: 1px solid #ff0000; padding: 0.5em; color: #ffffff; margin-bottom: 1em; }
        #errors ul { list-style-type: none; margin: 0; }
        
        .comment { border-bottom: 1px solid #a0a0a0; margin-bottom: 1em; }
        
        
        .clear { clear: both; }
        #footer { margin: 1em 0 0 0; padding-top: 1em; border-top: 1px solid #a0a0a0; }
      }
    end
  end

  class ShowUser < R '/(.+)'
    def get(name)
      @user = User.find_by_name(name)
      render :yours
    end
  end
end

module Mancodes::Helpers
  def add_success(msg)
    @state[:flash] = {} unless @state.key? :flash
    @state[:flash][:success] = [] unless @state[:flash].key? :success
    @state[:flash][:success] << msg
  end
  def add_error(msg)
    @state[:flash] = {} unless @state.key? :flash
    @state[:flash][:errors] = [] unless @state[:flash].key? :errors
    @state[:flash][:errors] << msg
  end

  def label_for name, record = nil, attr = name, options = {}
    errors = record && !record.valid? && record.errors.on(attr)
    label name.to_s.humanize, { :for => name }, options.merge(errors ? { :class => :error } : {})
  end



  # login system
  def current_user
    @current_user ||= Mancodes::Models::User.find(@state.user_id) unless @state.user_id.blank?
  end
  alias logged_in? current_user
  
  def login name, password
    @current_user = Mancodes::Models::User.find_by_name_and_password input.name, input.password
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

  def nice_paragraphs(str)
    str.split(/(?:\r\n|\r|\n)(?:\r\n|\r|\n)/).map { |p| "<p>#{p.encode_entities}</p>" }.join
  end
end

module Mancodes::Views
  def layout
    xhtml_transitional do
      head do
        title "Mancodes"
        link :rel => 'stylesheet', :type => 'text/css', :href => '/style.css', :media => 'screen'
      end
      body do
        div.header! do
          links = if logged_in?
            ["Logged in as #{current_user.name}", a('Logout', :href => '/logout')]
          else
            [a('Login', :href => '/login'), a('Signup', :href => '/signup')]
          end
          div.user_nav! { links.join(" | ") }
          h1 { a("Mancodes", :href => '/') }
          div.nav! do
            ul do
              li { a 'Home', :href => '/' }
              li { a 'Most popular', :href => '/popular' }
              li { a 'Newest', :href => '/newest' }
              li { a('Yours', :href => "/#{current_user.name}") } if logged_in?
              li { a('New', :href => "/create") } if logged_in?
            end
          end
        end
        div.main! do
          @state[:flash] = {} unless @state.key? :flash
          @state[:flash][:success] = [] unless @state[:flash].key? :success
          unless @state[:flash][:success].empty?
            div.success! do
              ul do
                @state[:flash][:success].each { |s| li { s } }
              end
            end
          end
          @state[:flash][:success] = []

          @state[:flash][:errors] = [] unless @state[:flash].key? :errors
          unless @state[:flash][:errors].empty?
            div.errors! do
              p { "There were some errors:" }
              ul do
                @state[:flash][:errors].each { |s| li { s } }
              end
            end
          end
          @state[:flash][:errors] = []

          self << yield
        end
        p.footer! { "Created by #{a "Brenton Fletcher", :href => "http://i.bloople.net"} in #{File.stat(__FILE__).size} bytes of code. <a href='mailto:&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;'>Email me</a>! Made on a #{a "Mac", :href => "http://apple.com"}. Powered by #{a "Ruby", :href => "http://rubyonrails.org"} on #{a "Camping", :href => "http://code.whytheluckystiff.net/camping/"}." }
      end
    end
  end

  def index
    h2 { "Most popular mancodes" }
    ul.mancodes do
      @popular_mancodes.each do |mc|
        li { a mc.name, :href => R(Show, mc) }
      end
      li { a 'More...', :href => '/popular' }
    end
    h2 { "Most recently created mancodes" }
    ul.mancodes do
      @new_mancodes.each do |mc|
        li { a mc.name, :href => R(Show, mc) }
      end
      li { a 'More...', :href => '/newest' }
    end
  end

  def popular
    h2 { "Most popular mancodes" }
    ul.mancodes do
      @mancodes.each do |mc|
        li { "#{a mc.name, :href => R(Show, mc)} • #{mc.score}" }
      end
    end
  end

  def newest
    h2 { "Most recently created mancodes" }
    ul.mancodes do
      @mancodes.each do |mc|
        li { "#{a mc.name, :href => R(Show, mc)} • #{mc.score}" }
      end
    end
  end

  def show
    h2 { @mancode.name }
    h3 { "Action" }
    text nice_paragraphs(@mancode.action)
    h3 { "Meaning" }
    text nice_paragraphs(@mancode.meaning)
    p { "Created by #{a @mancode.user.name, :href => R(ShowUser, @mancode.user.name)}, last updated at #{nice_date_time(@mancode.updated_at)}" }
    if logged_in? and current_user.id == @mancode.user_id
      h3 { "Modify Mancode" }
      p { "#{a 'Edit', :href => R(Update, @mancode)} • #{a 'Delete', :href => R(Destroy, @mancode)}" }
    end
    h3 { "Rating" }
    p { "Current score is #{@mancode.score}. #{(logged_in? ? "#{a 'Vote up', :href => R(VoteUp, @mancode), :rel => 'nofollow'} • #{a 'Vote down', :href => R(VoteDown, @mancode), :rel => 'nofollow'}" : '')}" }
    h3 { "Comments" }
    unless @mancode.comments.empty?
      @mancode.comments.each do |comment|
        div.comment do
          p { comment.body }
          p { "Posted by #{a comment.user.name, :href => R(ShowUser, comment.user.name)} at #{nice_date_time(comment.created_at)}" }
        end
      end
    else
      p { "No comments yet. Hey, why not add one?" }
    end
    h4 { "Post a comment" }
    if logged_in?
      form :method => :post, :action => R(Show, @mancode) do
        div do
          label_for :body, @comment
          input.text :name => :body, :type => :text, :size => 40, :value => @comment.body
        end
        div do
          input.submit :type => :submit, :value => 'Post comment'
        end
      end
    else
      p { "You could post a comment if you were #{a 'logged in', :href => '/login'}!" }
    end
  end

  def _form
    div do
      label_for :name, @mancode
      input.text :name => :name, :type => :text, :size => 40, :value => @mancode.name
    end
    div do
      label_for :action, @mancode
      textarea @mancode.action, :name => :action, :cols => 80, :rows => 10
    end
    div do
      label_for :meaning, @mancode
      textarea @mancode.meaning, :name => :meaning, :cols => 80, :rows => 10
    end
    div do
      input.submit :type => :submit, :value => 'Save'
    end
  end

  def create
    h2 { "Create Mancode" }
    form :method => :post, :action => '/create' do
       _form
    end
  end

  def update
    h2 { "Update #{@mancode.name}" }
    form :method => :post, :action => R(Update, @mancode) do
       _form
    end
  end


  def login
    form :action => R(Login), :method => :post do
      div do
        label_for :name
        input :name => :name, :type => :text
      end
      div do
        label_for :password
        input :name => :password, :type => :password
      end
      div do
        input.submit :type => :submit, :name => :login, :value => 'Login'
      end
    end
  end

  def signup
    form :action => R(Signup), :method => :post do
      div do
        label_for :name
        input :name => :name, :type => :text
      end
      div do
        label_for :password
        input :name => :password, :type => :password
      end
      div do
        label_for :email
        input :name => :email, :type => :text
      end
      div do
        input.submit :type => :submit, :name => :login, :value => 'Login'
      end
    end
  end

  def yours
    h2 { "#{@user.name.pluralize} mancodes"}
    ul do
      @user.mancodes.each { |mc| li { a mc.name, :href => R(Show, mc) } }
      li { "#{logged_in? and current_user.id == @user.id ? 'You haven\'t' : "#{@user.name} hasn't"} created any mancodes yet." } if @user.mancodes.empty?
      li { a 'Create mancode', :href => 'create' } if logged_in?
    end
  end
end

def Mancodes.create
  Mancodes::Models.create_schema
  ActiveRecord::Base.default_timezone = :utc
end