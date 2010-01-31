# encoding: utf-8

require 'camping/session'
require 'htmlentities/string'

Camping.goes :Concise

module Concise
  include Camping::Session
end

module Concise::Models
  class Question < Base
    validates_presence_of :body
    validates_length_of :body, :maximum => 150
    has_many :responses, :order => '((positive_votes / (positive_votes + negative_votes)) * 10) DESC, LENGTH(body) ASC'
  end
  
  class Response < Base
    belongs_to :question
    belongs_to :user
    has_many :votes
    validates_presence_of :body
    validates_length_of :body, :maximum => 150
    def score
      ((positive_votes.to_f / (positive_votes + negative_votes)) * 10).round
    end
  end

  class User < Base
    validates_uniqueness_of :name
    has_many :responses
    has_many :votes
  end

  class Vote < Base
    belongs_to :user
    belongs_to :response
  end

  class CreateConcise < V 0.1
    def self.up
      create_table :concise_questions, :force => true do |t|
        t.column :body, :string
        t.datetime :created_at, :updated_at
      end
      create_table :concise_responses, :force => true do |t|
        t.column :user_id, :integer
        t.column :question_id, :integer
        t.column :body, :string
        t.integer :positive_votes, :negative_votes
        t.datetime :created_at, :updated_at
      end
      create_table :concise_users, :force => true do |table|
        table.string :name, :password, :email
      end
      create_table :concise_votes, :force => true do |table|
        table.integer :user_id, :response_id
        table.boolean :positive
      end
    end
  end
end

module Concise::Controllers
  class Index < R '/'
    def get
      @new_questions = Question.find(:all, :order => 'created_at DESC', :limit => 20) || []
      @popular_questions = Question.find(:all, :select => "concise_questions.*, COUNT(concise_responses.id) AS occurences",
       :joins => :responses, :group => "concise_questions.id", :order => "occurences DESC", :limit => 20) || []
      render :index
    end
  end

  class Create
    def get
      #return unless admin?
      return unless logged_in?
      @question = Question.new
      render :create
    end

    def post
      #return unless admin?
      return unless logged_in?
      @question = Question.new(:body => input.body)
      if @question.save
        add_success("Question created")
        redirect "/#{@question.id}"
      else
        @question.errors.full_messages.each { |msg| add_error(msg) }
        render :create
      end
    end
  end

  class Update < R '/(\d+)/update'
    def get(id)
      #return unless admin?
      return unless logged_in?
      @question = Question.find_by_id(id.to_i)
      render :update
    end

    def post(id)
      #return unless admin?
      return unless logged_in?
      @question = Question.find_by_id(id.to_i)
      if @question.update_attributes(:body => input.body)
        add_success("Question updated")
        redirect "/#{@question.id}"
      else
        @question.errors.full_messages.each { |msg| add_error(msg) }
        render :update
      end
    end
  end

  class Destroy < R '/(\d+)/destroy'
    def get(id)
      return unless admin?
      @question = Question.find_by_id(id.to_i).destroy
      add_success("Question deleted")
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
        add_success("User created.")
        redirect '/login'
      else
        @user.errors.full_messages.each { |msg| add_error(msg) }
        render :signup
      end
    end
  end

  class Show < R '/(\d+)'
    def get(id)
      @question = Question.find(id.to_i)
      @resp = Response.new
      render :show
    end

    def post(id)
      return unless ensure_logged_in
      @question = Question.find(id.to_i)
      @resp = Response.new(:question => @question, :user_id => current_user.id, :body => input.body, :positive_votes => 1, :negative_votes => 1)
      if @resp.save
        add_success("Response posted")
        redirect "/#{id}"
      else
        @resp.errors.full_messages.each { |msg| add_error(msg) }
        render :show
      end
    end
  end
  
  class VoteUp < R '/responses/(\d+)/up'
    def get(id)
      return unless ensure_logged_in
      @resp = Response.find(id.to_i)
      existing_vote = @resp.votes.find_by_user_id(current_user.id)
      if existing_vote
        if existing_vote.positive?
          add_error("You've already voted up this response.")
        else
          existing_vote.toggle!(:positive)
          @resp.negative_votes -= 1
          @resp.positive_votes += 1
          @resp.save
          add_success("Your vote has been changed from down to up.")
        end
      else
        @resp.votes.create(:user => current_user, :positive => true)
        @resp.increment!(:positive_votes)
        add_success("Your vote has been cast.")
      end
      redirect R(Show, @resp.question)
    end
  end

  class VoteDown < R '/responses/(\d+)/down'
    def get(id)
      return unless ensure_logged_in
      @resp = Response.find(id.to_i)
      existing_vote = @resp.votes.find_by_user_id(current_user.id)
      if existing_vote
        if !existing_vote.positive?
          add_error("You've already voted down this response.")
        else
          existing_vote.toggle!(:positive)
          @resp.negative_votes += 1
          @resp.positive_votes -= 1
          @resp.save
          add_success("Your vote has been changed from up to down.")
        end
      else
        @resp.votes.create(:user => current_user, :positive => false)
        @resp.increment!(:negative_votes)
        add_success("Your vote has been cast.")
      end
      redirect R(Show, @resp.question)
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
        ul { margin: 1em 0 1em 1.5em; }
        label { width: 5em; display: block; float: left; text-align: right; padding: 0.2em 0.3em 0 0; }
        input { width: 20em; }
        input.submit { margin-left: 5.3em; width: 8em; }
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

  class ShowUser < R '/users/(.+)'
    def get(name)
      @user = User.find_by_name(name)
      render :yours
    end
  end

  #static stuff follows
  class About
    def get
      render :about
    end
  end
end

module Concise::Helpers
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
    @current_user ||= Concise::Models::User.find(@state.user_id) unless @state.user_id.blank?
  end
  alias logged_in? current_user
  
  def login name, password
    @current_user = Concise::Models::User.find_by_name_and_password input.name, input.password
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

  def admin?
    current_user.id == 1
  end


  def nice_date_time(date)
    return date.strftime("%d/%m/%Y %I:%M%p")
  end

  def h(text)
    CGI::escapeHTML(text)
  end
end

module Concise::Views
  def layout
    xhtml_transitional do
      head do
        title "Concise"
        link :rel => 'stylesheet', :type => 'text/css', :href => '/style.css', :media => 'screen'
      end
      body do
        div.header! do
          links = [a('Home', :href => '/'), a('About', :href => '/about')] + if logged_in?
            ["Logged in as #{a current_user.name, :href => R(ShowUser, current_user.name)}", a('Post a question', :href => '/create'), a('Logout', :href => '/logout')]
          else
            [a('Login', :href => '/login'), a('Signup', :href => '/signup')]
          end
          div.nav! { links.join(" | ") }
          h1 { a("Concise", :href => '/') }
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
        p.footer! { "Created by #{a "Brenton Fletcher", :href => "http://blog.bloople.net"} in #{File.stat(__FILE__).size} bytes of code. " +
         "<a href='mailto:&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;'>Email me</a>! Powered by " +
         "#{a "Ruby", :href => "http://ruby-lang.org"} on #{a "Camping", :href => "http://github.com/camping/camping/"}." }
      end
    end
  end

  def index
    div.column do
      h2 { "Most recent questions" }
      ul.concise do
        @new_questions.each do |q|
          li { a q.body, :href => R(Show, q) }
        end
      end
    end
    div.column do
      h2 { "Most popular questions" }
      ul.concise do
        @popular_questions.each do |q|
          li { a q.body, :href => R(Show, q) }
        end
      end
    end
    div.clear { " " }
  end

  def show
    h2 { "Question" }
    p { h @question.body }
    if logged_in?# and admin?
      h2 { "Modify Question" }
      p { "#{a 'Edit', :href => R(Update, @question)} • #{a 'Delete', :href => R(Destroy, @question)}" }
    end
    h2 { "Responses" }
    unless @question.responses.empty?
      @question.responses.each do |response|
        div.response do
          p { "#{h response.body} • #{a response.user.name, :href => R(ShowUser, response.user.name)} • #{logged_in? ? (a '+', :href => R(VoteUp, response)) : ''} #{response.score} #{logged_in? ? (a '-', :href => R(VoteDown, response)) : ''}" }
        end
      end
    else
      p { "No responses yet. Hey, why not add one?" }
    end
    h3 { "Post a response" }
    if logged_in?
      form :method => :post, :action => R(Show, @question) do
        div do
          label_for :body, @resp
          input.text :name => :body, :type => :text, :size => 40, :value => @resp.body
        end
        div do
          input.submit :type => :submit, :value => 'Post response'
        end
      end
    else
      p { "You could post a response if you were #{a 'logged in', :href => '/login'}!" }
    end
  end

  def _form
    div do
      label_for :body, @question
      input.text :name => :body, :type => :text, :size => 40, :value => @question.body
    end
    div do
      input.submit :type => :submit, :value => 'Save'
    end
  end

  def create
    h2 { "Create Question" }
    form :method => :post, :action => '/create' do
       _form
    end
  end

  def update
    h2 { "Update Question" }
    form :method => :post, :action => R(Update, @question) do
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
        input.submit :type => :submit, :name => :login, :value => 'Signup'
      end
    end
  end

  def yours
    h2 { "#{h @user.name.pluralize} responses"}
    ul do
      @user.responses.each { |r| li { a r.question.body, :href => R(Show, r.question) } }
      li { "#{logged_in? and current_user.id == @user.id ? 'You haven\'t' : "#{h @user.name} hasn't"} created any responses yet." } if @user.responses.empty?
    end
  end

  #static stuff follows

  def about
    h2 { "About Concise" }
    p { "Concise is a list of questions and an attempt to answer those questions elegantly in as few words as possile." }
    p { "The questions are (currently) posted by the moderator of this site, #{a 'Brenton Fletcher', :href => "http://blog.bloople.net"}. You can ask for a question to be posted on this site by #{a 'emailing Brenton', :href => "mailto:i@bloople.net"}. Brenton will attempt to post questions covering a range of topics, so that there's something for everyone." }
    p { "The answers are supplied by you, the user. For each question, the answers are displayed in order of score, then by how short they are. You can vote up an answer if you think it's good (and you can vote the answer down if you think it's bad!)." }
    p { "Answers are limited in length to 140 characters - just like Twitter. Hopefully this site can, like Twitter, help people express themselves eloquently in a short space."}
  end
end

def Concise.create
  Concise::Models.create_schema
  ActiveRecord::Base.default_timezone = :utc
end