# encoding: utf-8

require 'camping/session'
require 'htmlentities/string'
require 'gruff'
require 'lib/has_image'
require 'lib/common'
require 'lib/linear_regression'
require 'kc/models'

Camping.goes :Akc

module Akc
  include Camping::Session
  PATH = File.expand_path(File.dirname(__FILE__)) + '/akc'
end

module Akc::Models
  include KcModels

  class CreateAkc < V 6
    def self.up
      create_table "akc_scores", :force => false do |t|
        t.integer  "version", "user_id", "score"
        t.datetime "when"
        t.string   "source"
      end

      create_table "akc_shouts", :force => false do |t|
        t.string   "username", "text"
        t.datetime "posted"
      end

      create_table "akc_users", :force => false do |t|
        t.string  "name", "crypt"
        t.integer "high_score"
        t.integer :view_count, :default => 0
        t.datetime :scores_when, :default => nil
        t.integer :top_score_id
        t.integer :latest_score_id
        t.integer :total_scores
        t.boolean "has_avatar", :default => false
      end
    end
  end
end

module Akc::Controllers
  class CheckOutAkc < R '/check_out_akc/(\d+)'
    def get(id)
      @user = User.find(id)
      render :check_out_akc
    end
  end

  class Index < R '/'
    def get
      #z = Time.now
      @users = User.find(:all, :include => :latest_score, :order => 'high_score DESC, akc_scores.when DESC', :limit => 3)
      @scores = Score.find(:all, :include => :user, :order => 'score DESC', :limit => 3)
      @users_by_scores_submitted = User.find(:all, :order => 'total_scores DESC', :limit => 3)
      @shouts = Shout.find(:all, :order => "posted DESC", :limit => 5)
      @shout = Shout.new
      @user = User.new
      @user_count = User.count
      @score_count = Score.count
      #puts "time in controller: #{Time.now - z}"
      render :index
    end
  end

  class UpdateUser < R '/users/update'
    def get
      return unless logged_in?
      @user = current_user
      render :update_user
    end

    def post
      return unless logged_in?
      @user = current_user
      if @user.update_attributes(:has_avatar => input.has_avatar, :avatar => (!input.avatar.nil? ? input.avatar[:tempfile] : nil))
        add_success("User updated")
        redirect "/users/#{@user.id}"
      else
        @user.errors.full_messages.each { |msg| add_error(msg) }
        render :update_user
      end
    end
  end

  class AddScore < R '/add/(|.*?/)(\d+)/(.*?)/(.*?)/(\d+)'
    def get(source, version, name, crypt, score)
      source = (source == '' ? 'konfabulator' : source.chop)
      if true#version == 11 or (source == 'konfabulator' and version == 10)
        user = User.find_by_name(name)
        if user
          unless user.crypt == crypt
            mab { text "0|http://akc.bloople.net/invalidcrypt" }
            return
          end
        else
          user = User.create(:name => name, :crypt => crypt)
        end

        Score.create(:version => version, :user => user, :score => score, :when => Time.now.getgm, :source => source)

        mab { text "" }
      else
        mab { text "1|http://akc.bloople.net/pleaseupgrade" }
      end
    end
  end
  
  class HighScores < R '/high_scores'
    def get
      @scores = Score.find(:all, :include => :user, :order => 'score DESC', :limit => 1000)
      @users = User.find(:all, :include => :latest_score, :order => 'high_score DESC, akc_scores.when DESC', :limit => 1000)
      render :high_scores
    end
  end

  class HighScoresAbsolute < R '/high_scores_absolute.rss'
    def get
      @scores = Score.find(:all, :include => :user, :order => 'score DESC', :limit => 50)
      render :high_scores_absolute
    end
  end

  class HighScoresAverage < R '/high_scores_average.rss'
    def get
      @scores = Score.find(:all, :include => :user, :order => 'score DESC', :limit => 50)
      @users = User.find(:all, :include => :latest_score, :order => 'high_score DESC, akc_scores.when DESC', :limit => 50)
      render :high_scores_average
    end
  end

  class Statistics
    def get
      render :statistics
    end
  end

  class ScoresByDateGraph < R '/scores_by_date_graph'
    def get
      scores = ActiveRecord::Base.connection.select_all("SELECT COUNT(id) AS count, DATE(akc_scores.when) AS date FROM akc_scores GROUP BY DATE(akc_scores.when) ORDER BY DATE(akc_scores.when) ASC")

      days = []
      counts = []
      scores.each do |s|
        days << Date.parse(s['date'])
        counts << s['count'].to_i
      end

      g = Gruff::Line.new('984x480')
      g.instance_variable_set(:@raw_columns, 1230.0)
      g.instance_variable_set(:@raw_rows, 600)
      g.instance_variable_set(:@scale, 0.8)
      g.data("Scores", counts)

      lr = LinearRegression.new(counts)
      g.data("Trend line", lr.fit)

      g.labels = { 0 => "#{days.first.mday} #{Date::MONTHNAMES[days.first.month]} #{days.first.year}", (days.size - 1) => "#{days.last.mday} #{Date::MONTHNAMES[days.last.month]} #{days.last.year}" }
      g.theme_37signals
      g.minimum_value = [lr.fit.min, 0].min
      g.title = "Scores submitted per day"

      @headers['Content-Type'] = 'image/png'
      @headers['Content-Disposition'] = 'inline'
      g.to_blob
    end
  end

  class HighScoresGraph < R '/high_scores_graph'
    def get
      scores = Score.find(:all, :order => "score DESC", :limit => 50)

      g = Gruff::Line.new('984x480')
      g.instance_variable_set(:@raw_columns, 1230.0)
      g.instance_variable_set(:@raw_rows, 600)
      g.instance_variable_set(:@scale, 0.8)
      g.data("Scores", scores.map { |s| s.score })

      labels = {}
      scores.each_with_index do |s, i|
        labels[i] = s.when if labels.empty? or (labels.values.last.month != s.when.month)
      end
      labels.each_pair { |(key, val)| labels[key] = "#{Date::MONTHNAMES[val.month]} #{val.year}" }

      lr = LinearRegression.new(scores.map { |s| s.score })
      g.data("Trend line", lr.fit)

      first = scores.first.when
      last = scores.last.when
      g.labels = { 0 => "#{first.mday} #{Date::MONTHNAMES[first.month]} #{first.year}", (scores.size - 1) => "#{last.mday} #{Date::MONTHNAMES[last.month]} #{last.year}" }
      g.theme_37signals
      g.minimum_value = [lr.fit.min, 0].min
      g.title = "Top 50 high scores"

      @headers['Content-Type'] = 'image/png'
      @headers['Content-Disposition'] = 'inline'
      g.to_blob
    end
  end

  class ScoresForUser < R '/scores_for_user'
    def post
      @search_term = input.name
      @users = User.find(:all, :conditions => "name LIKE #{ActiveRecord::Base.connection.quote("%#{@search_term}%")}")
      render :scores_for_user
    end
  end

  class LatestScoresByUser < R '/users/(\d+)/latest_scores.rss'
    def get(id)
      @user = User.find(id)
      @scores = @user.scores.find(:all, :order => 'akc_scores.when DESC', :limit => 50)
      render :latest_scores_by_user
    end
  end

  class HighScoresByUser < R '/users/(\d+)/high_scores.rss'
    def get(id)
      @user = User.find(id)
      @scores = @user.scores.find(:all, :order => 'score DESC', :limit => 50)
      render :high_scores_by_user
    end
  end

  class Login < R '/users/login', '/users/logout'
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

  class ShowUser < R '/users/(\d+)'
    def get(id)
      @user = User.find(id)
      @latest_scores = @user.scores.find(:all, :order => 'akc_scores.when DESC', :limit => 10)
      @high_scores = @user.scores.find(:all, :order => 'score DESC', :limit => 10)
      @first_score = @user.scores.find(:first, :order => 'akc_scores.when ASC', :limit => 1)
      @user.increment!(:view_count)
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

  class ShowAllScoresForUser < R '/users/(\d+)/all_scores'
    def get(id)
      @user = User.find(id)
      @scores = @user.scores.find(:all, :order => 'akc_scores.when DESC')
      render :show_all_scores_for_user
    end
  end
  
  class ShowUserScoresGraph < R '/users/(\d+)/scores_graph'
    def get(id)
      @user = User.find(id)
      @scores = @user.scores.find(:all, :include => :user, :order => "akc_scores.when ASC")

      g = Gruff::Line.new('984x480')
      g.instance_variable_set(:@raw_columns, 1230.0)
      g.instance_variable_set(:@raw_rows, 600)
      g.instance_variable_set(:@scale, 0.8)
      
      g.data("Scores", @scores.map { |s| s.score })

      labels = {}
      @scores.each_with_index do |s, i|
        labels[i] = s.when if labels.empty? or (labels.values.last.month != s.when.month)
      end
      labels.each_pair { |(key, val)| labels[key] = "#{Date::MONTHNAMES[val.month]} #{val.year}" }

      lr = LinearRegression.new(@scores.map { |s| s.score })
      g.data("Trend line", lr.fit)

      g.labels = labels
      g.theme_37signals
      g.minimum_value = [lr.fit.min, 0].min
      g.title = "Scores over time"

      @headers['Content-Type'] = 'image/png'
      @headers['Content-Disposition'] = 'inline'
      g.to_blob
    end
  end

  class AddShout < R '/add_shout'
    def post
      Shout.create(:username => input.username, :text => input.text, :captcha => input.captcha, :posted => Time.now.getgm)
      redirect '/'
    end
  end

  include StaticAssetsClass
end

module Akc::Helpers
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
    @current_user ||= Akc::Models::User.find(@state.user_id) unless @state.user_id.blank?
  end
  alias logged_in? current_user
  
  def login name, password
    @current_user = Akc::Models::User.find_by_name_and_crypt input.name, input.password
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

  def large_avatar(user)
    user.has_avatar? ? (img :src => user.avatar_large_url, :class => 'avatar') : ''
  end

  def small_avatar(user)
    user.has_avatar? ? (img :src => user.avatar_small_url, :class => 'avatar') : ''
  end

  def image_column(record, name)
    has_file = record.send("has_#{name}?")
    out = "<div class='upload'>#{has_file ? img(:src => record.send("#{name}_url")) : ""}<div>"
    out << "#{input :type => :radio, :name => "has_#{name}", :value => '0', :onclick => "$('#{name}').disabled = true;", :class => 'radio'} No file<br />"
    out << "#{input :type => :radio, :name => "has_#{name}", :value => '1', :onclick => "$('#{name}').disabled = true;", :class => 'radio', :checked => 'checked'} Keep same file<br />" if has_file
    attrs = { :type => :radio, :name => "has_#{name}", :value => '1', :onclick => "$('#{name}').disabled = false;", :class => 'radio' }
    attrs[:checked] = "checked" if !has_file
    out << "#{input attrs} Upload new file"
    attrs = { :type => :file, :name => name, :id => name, :class => 'file' }
    attrs[:disabled] = "disabled" if has_file
    attrs[:checked] = "checked" if !has_file
    out << "#{input attrs}</div><div class='clear'></div></div>"
    out
  end

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

module Akc::Views
  def layout
    content = yield
#    puts "content: #{content.inspect}"
    @content_for ||= {}
    if @render_layout.nil?
      @render_layout = true
    end

    if @render_layout
      xhtml_transitional do
        head do
          title "ArrowKeyControl"
          link :rel => 'stylesheet', :type => 'text/css', :href => '/style.css', :media => 'screen'
          script :type => 'text/javascript', :src => '/application.js'
          link :rel => 'shortcut icon', :href => '/favicon.ico'
          self << @content_for[:head]
        end
        body do
          div.wrap! do
            div.header! do
              h1 { a("ArrowKeyControl", :href => '/') }
              links = if logged_in?
                ["Logged in as #{current_user.name}", a('Customise', :href => "/users/update"), a('Your Scores', :href => "/users/#{current_user.id}"), a('Logout', :href => '/users/logout')]
              else
                [a('Login', :href => '/users/login')]
              end
              div.nav! { links.join(" | ") }
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

              self << content
            end
            div.footer! do
              p { "&copy; 2009 Brenton Fletcher. Check out <a href=\"http://blog.bloople.net\">my blog</a>. Comments? <a href=\"mailto:i@bloople.net\">i@bloople.net</a>. Made on a Mac with Camping." }
            end
          end
        end
      end
    else
      self << content
    end
  end

  def index
   #z = Time.now
    @content_for = {}

    div.col_right do
      h2 { "Statistics" }
      p { "<span class=\"bignum\">#{number_with_delimiter @score_count}</span> scores submitted by <span class=\"bignum\">#{number_with_delimiter @user_count}</span> users" }
      p { a("More statistics...", :href => '/statistics') }
      h2 { "Top 3 Averaged High Scores" }
      _scores_by_users(@users)
      h2 { "Top 3 Individual High Scores" }
      _scores(@scores, true)
      h2 { "Top 3 Users by Number of Scores Submitted" }
      table.scores do
        tr do
          td { "No. submitted" }
          td { "Username" }
          td.last_r { "Last active" }
        end

        @users_by_scores_submitted.each do |u|
          last_active = u.latest_score.when
          
          attrs = {}
          attrs['class'] = 'last_b' if u == @users_by_scores_submitted.last
          tr attrs do
            td.score { number_with_delimiter(u.scores.count) }
            td { a(h(u.name), :href => "/users/#{u.id}") }
            text "<td class='last_r' rel='#{last_active.to_i * 1000}'>#{nice_date_time last_active}</td>"
          end
        end
      end

      form :method => :post, :action => '/scores_for_user', :id => 'scores' do
        input :type => 'text', :name => 'name', :value => "Type a user's name to get their scores", :id => "scores-username"
      end
      p { a("More high scores...", :href => '/high_scores') }

      h2 { "Shoutbox" }
      div.shouts! { _shoutbox(@shouts) }
      p.utc! { "Note: all dates are in <acronym title=\"Greenwich Mean Time\">GMT</acronym> / <acronym title=\"Coordinated Universal Time\">UTC</acronym>." }
      p.local! { "Note: all dates are in your local time." }
    end

#    types = [:playinbrowser, :apple, :yahoo]
    types = [:apple]

    div.col_left do
=begin
      h2 { "News" }
      text '<script id="feed-122131857610955" type="text/javascript" src="http://rss.bloople.net/?url=http%3A%2F%2Fblog.bloople.net%2Frss%2FArrowKeyControl&amp;detail=25&amp;limit=5&amp;showtitle=false&amp;striphtml=true&amp;type=js&amp;id=122131857610955"></script>'
=end
      h2 { "About" }
      div.screenshot do
        img :src => '/images/screenshot.png'
        text "Screenshot of ArrowKeyControl"
      end
      p { "ArrowKeyControl is a fast-paced game for the Apple Dashboard, Yahoo! Widgets, and your browser, that tests your speed." }
      p { "The idea is simple - the game shows an arrow, and you have to hit the corresponding arrow key; get it right, and you go again; get it wrong, or hit the key too slowly, and it's game over. Did I mention you have to keep getting faster all the time?" }
      p { "The faster you are, the more you score. Your scores are automatically submited to this web site, so you can compare scores with other players." }
      h2 { "How to Play" }
      ol do
        li { "To begin a game, click the Play button on the widget. You will have 1.5 seconds to get ready." }
        li { "The widget will then display an arrow. You have to hit the corresponding arrow key as fast as possible - you've got 1 second to hit the first key." }
        li { "While the game is showing the arrow, the background of the game fills from left to right in red - this shows how much time you hav left to hit the key; if this fills up before you hit the key, the game ends." }
        li { "The faster you press the correct key, the more you score. The game then displays another arrow key (sometimes the same one as the last one), and reduces the amount of time you have to hit the next key (so you have to get faster!)." }
        li { "This continues until you aren't fast enough to keep up with the computer, or you hit the wrong key." }
      end
      h2 { "How to get ArrowKeyControl" }
      p.manual! { '<a name="download"></a>Please select your platform, then follow the correct download instructions below:' }
      div.choice! do
        ul do
          #li { '<a href="#download" onclick="show(\'playinbrowser\');">Play in your browser</a>' }
          li { '<a href="#download" onclick="show(\'apple\');">Download for the Apple Dashboard</a>' }
          #li { '<a href="#download" onclick="show(\'yahoo\');">Download for Yahoo! Widgets</a>' }
        end
      end

      types.each do |type|
        div(:id => type) {}
      end
    end

    @content_for[:apple] = capture(true) do
      h3 { "Get ArrowKeyControl for the Apple Dashboard" }
      ol do
        li do
          text "Which web browser are you using?"
          ul do
            li { "If you're using Safari, click the download link below." }
            li { "If you're using another browser, click the download link. When the widget download is complete, unarchive it and place it in /Library/Widgets/ in your home folder.</li>" }
          end
        end
        li { "Show Dashboard, click the Plus sign to display the Widget Bar and click the widget's icon in the Widget Bar to open it." }
      end
      p { '<a href="/ArrowKeyControl.zip">Download now</a>' }
    end
=begin
    @content_for[:yahoo] = capture(true) do
      h3 { "Get ArrowKeyControl on Yahoo! Widgets" }
      p { "Click the Open Widget button below:" }
      text "<iframe scrolling=\"no\" frameborder=\"0\" src=\"http://badge.ydp.clientapps.yahoo.com/badge/widgets/badge?aid=w6344&amp;tc=cccccc&amp;bc=303030&amp;cn=keycontrol\" style=\"width:180px;height:190px;padding:0;border:0;\" allowTransparency=\"true\"></iframe>"
    end
    @content_for[:playinbrowser] = capture(true) do
      h3 { "Play in your browser" }
      p { "You can play ArrowKeyControl right here in your browser. Just click the Play button below to begin!" }
      text "<object type=\"application/x-shockwave-flash\" data=\"/ArrowKeyControl.swf\" width=\"187\" height=\"140\"><param name=\"movie\" value=\"/ArrowKeyControl.swf\" /></object>"
    end
=end

    noscript.noscript! do
      text(types.map { |type| @content_for[type] }.join("\n\n"))
    end

    @content_for[:head] = capture(true) do
      link :href => '/high_scores_absolute.rss', :rel => 'alternate', :title => 'RSS feed of individual high scores', :type => 'application/rss+xml'
      link :href => '/high_scores_average.rss', :rel => 'alternate', :title => 'RSS feed of averaged high scores', :type => 'application/rss+xml'
      script :type => 'text/javascript' do
        text "var types = {#{types.map { |type| "\"#{type}\": \"#{@content_for[type].gsub('"', '\"').gsub("\n", "")}\"" }.join(", ")}};" 
      end
    end

    div.clear { " " }
    #puts "Time in view method: #{Time.now - z}"
  end

  def show
    @content_for = {}
    @content_for[:head] = capture(true) do
      link :href => "/users/#{@user.id}/latest_scores.rss", :rel => 'alternate', :title => 'RSS feed latest scores', :type => 'application/rss+xml'
      link :href => "/users/#{@user.id}/high_scores.rss", :rel => 'alternate', :title => 'RSS feed for top scores', :type => 'application/rss+xml'
    end

    h2 { h(@user.name) + "'s Profile" }
    div.clear { "" }

    div.user_show_col_right do
      h3 { "Top 10 scores" }
      _scores(@high_scores, false)
      p { a('All of ' + h(@user.name) + '\'s scores', :href => "/users/#{@user.id}/all_scores") }
      p { a('RSS feed for top scores', :href => "/users/#{@user.id}/high_scores.rss") }
    end

    div.user_show_col_middle do
      h3 { "Latest 10 scores" }
      _scores(@latest_scores, false)
      p { a('All of ' + h(@user.name) + '\'s scores', :href => "/users/#{@user.id}/all_scores") }
      p { a('RSS feed for latest scores', :href => "/users/#{@user.id}/latest_scores.rss") }
    end

    div.user_show_col_left do
  #    h3 { "Avatar and Social Network" }
     # div.avatars_wrap! do
    #    span.avatar_wrap { large_avatar(@user) }
    #    div.friends! { "Coming soon..." }
#        ul.friends! do
#          @user.friends.each do |friend|
#            li { span.avatar_wrap { small_avatar(friend) } + friend.name }
#          end
#        end
     #   div.clear { " " }
    #  end

      h3 { "Summary" }
      table do
=begin
        tr do
          td { "Social network" + div.friends! { "Coming soon..." } }
          td(:class => 'last_r') do
            "Avatar" + span.avatar_wrap { large_avatar(@user) }
          end
        end
=end
        if @user.has_avatar?
          tr do
            td { "Avatar" }
            td(:class => 'last_r') do
              span.avatar_wrap { large_avatar(@user) }
            end
          end
        end
        tr do
          td { "Started submitting" }
          td(:class => 'last_r score_when', :rel => (@first_score.when.to_i * 1000)) { nice_date_time @first_score.when }
        end
        tr do
          td { "Number of scores submitted" }
          td.last_r { number_with_delimiter @user.scores.length }
        end
        tr do
          td { "Averaged high score" }
          td.last_r { number_with_delimiter @user.high_score }
        end
        tr do
          td { "Top individual score" }
          td.last_r { number_with_delimiter(@high_scores.first.score) }
        end
        tr do
          td { "Latest score" }
          td.last_r { number_with_delimiter(@latest_scores.first.score) }
        end
        tr.last_b do
          td { "Profile views" }
          td.last_r { @user.view_count }
        end
      end
    end

    img :src => "/users/#{@user.id}/scores_graph"

    p.utc! { "Note: all dates are in <acronym title=\"Greenwich Mean Time\">GMT</acronym> / <acronym title=\"Coordinated Universal Time\">UTC</acronym>." }
    p.local! { "Note: all dates are in your local time." }
    
    div.clear { " " }
  end

  def show_all_scores_for_user
    h2 { "All scores for #{h @user.name}" }
    _scores(@scores, false)
  end

  def high_scores
    div.col_right do
      h2 { "Top 1000 Individual High Scores" }
      _scores(@scores, true)
      p { a('RSS feed of individual high scores', :href => '/high_scores_absolute.rss') }
    end
    div.col_left do
      h2 { "Top 1000 Averaged High Scores" }
      _scores_by_users(@users)
      p { a('RSS feed of averaged high scores', :href => '/high_scores_average.rss') }
    end
    p.utc! { "Note: all dates are in <acronym title=\"Greenwich Mean Time\">GMT</acronym> / <acronym title=\"Coordinated Universal Time\">UTC</acronym>." }
    p.local! { "Note: all dates are in your local time." }
  end

  def statistics
    h2 { "Statistics" }
    p { img :src => "/scores_by_date_graph" }
    p { img :src => "/high_scores_graph" }
  end

  def scores_for_user
    h2 { "Users with '#{h @search_term}' in their username" }
    if @users.empty?
      p { "No users were found that matched your search term." }
    else
      table.scores do
        tr do
          th { "Username" }
          th { "Top score" }
          th.last_r { "Last active" }
        end

        @users.each do |u|
          last_active = u.scores.find(:first, :order => "akc_scores.when DESC")
          last_active = last_active.nil? ? "Never" : last_active.when
          top = u.scores.find(:first, :order => 'score DESC')
          top = top.nil? ? "None" : top.score
          
          attrs = {}
          attrs[:class] = "last_b" if u == @users.last
          tr(attrs) do
            td { tag!(:a, :href => "/users/#{u.id}") { small_avatar(u) + h(u.name) } }
            td.score { top.is_a?(String) ? top : number_with_delimiter(top) }
            td.last_r(:rel => last_active.to_i * 1000) { last_active.is_a?(String) ? last_active : nice_date_time(last_active) }
          end
        end
      end
    end
  end

  def high_scores_absolute
    @render_layout = false
    @headers['Content-Type'] = 'application/rss+xml'
    instruct! :xml, :version => '1.0'
    rss(:version => '2.0') do
      channel do
        title "Top 50 individual scores"
        for s in @scores
          item do
            title "#{s.user.name} scored #{number_with_delimiter s.score} at #{nice_date_time s.when}"
            description "#{s.user.name} scored #{number_with_delimiter s.score} at #{nice_date_time s.when} UTC."
            pubDate s.when.to_s(:rfc822)
            link({ :action => 'show', :id => s.user.id })
            guid({ :action => 'show', :id => s.user.id })
          end
        end
      end
    end
  end

  def high_scores_average
    @render_layout = false
    @headers['Content-Type'] = 'application/rss+xml'
    instruct! :xml, :version => '1.0'
    rss(:version => '2.0') do
      channel do
        title "Top 50 averaged high scores"
        for u in @users
          item do
            title "#{u.name} has an averaged high score of #{number_with_delimiter u.high_score}"
            description "#{u.name} has an average of #{number_with_delimiter u.high_score} over their last 100 scores, or if they have less than 100 scores submitted, the average of all their scores. #{u.name}'s latest score was submitted at #{nice_date_time u.latest_score.when} UTC."
            pubDate u.latest_score.when.to_s(:rfc822)
            link({ :action => 'show', :id => u.id })
            guid({ :action => 'show', :id => u.id })
          end
        end
      end
    end
  end

  def latest_scores_by_user
    @render_layout = false
    @headers['Content-Type'] = 'application/rss+xmll'
    instruct! :xml, :version => '1.0'
    rss(:version => '2.0') do
      channel do
       title "Latest 50 scores for #{@user.name}"
        for s in @scores
          item do
            title "#{number_with_delimiter s.score} at #{nice_date_time s.when}"
            description "#{@user.name} scored #{number_with_delimiter s.score} at #{nice_date_time s.when} UTC."
            pubDate s.when.to_s(:rfc822)
            link({ :action => 'show', :id => @user.id })
            guid({ :action => 'show', :id => @user.id })
          end
        end
      end
    end
  end

  def high_scores_by_user
    @render_layout = false
    @headers['Content-Type'] = 'application/rss+xml'
    instruct! :xml, :version => '1.0'
    rss(:version => '2.0') do
      channel do
       title "Top 50 scores for #{@user.name}"
        for s in @scores
          item do
            title "#{number_with_delimiter s.score} at #{nice_date_time s.when}"
            description "#{@user.name} scored #{number_with_delimiter s.score} at #{nice_date_time s.when} UTC."
            pubDate s.when.to_s(:rfc822)
            link({ :action => 'show', :id => @user.id })
            guid({ :action => 'show', :id => @user.id })
          end
        end
      end
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

  def update_user
    h2 { "Customise your account" }
    form :action => "/users/update", :method => :post, :enctype => 'multipart/form-data' do
      div do
        label_for :username
        span.readonly { @user.name }
      end
      div do
        label_for :password
        span.readonly { @user.crypt }
      end
      div do
        label_for :avatar_image
        text image_column(@user, 'avatar')
        end
      div do
        input :type => 'submit', :class => 'submit', :value => "Save"
      end
    end
  end


  def _shoutbox(shouts)
    table.shoutbox! do
      tr do
        th { a(:name => 'shoutbox') + "Shout" }
        th { "User" }
        th.last_r { "When" }
      end
      shouts.each do |s|
        attrs = {}
        attrs["class"] = 'last_b' if s == shouts[99] or s == shouts.last
        tr(attrs) do
          td { s.text }
          td { s.username + (s == shouts[99] or s == shouts.last ? a(:name => 'shoutbox_form') : '').to_s }
          td(:class => 'last_r shout', :rel => s.posted.to_i * 1000) { nice_date_time s.posted }
        end
      end
    end

    form :action => '/add_shout', :method => :post do
      div do
        label_for :username
        input :name => :username, :type => :text
      end
      div do
        label_for :text
        textarea :name => :text, :rows => 3
      end
      div do
        label(:for => 'shout_captcha') { "Enter the word on the right:" }
        img :src => "/images/captcha.png"
        input :name => :captcha, :type => :text
      end
      div do
        input :type => :submit, :class => :submit, :value => 'Say it!'
      end
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

  def _scores(scores, show_user)
    table.scores do
      tr do
        th { "Score" }
        th { "User" } if show_user
        th.last_r { "When" }
      end

      scores.each do |s|
        text "<tr#{s == scores.last ? ' class=\'last_b\'' : ''}><td>#{number_with_delimiter(s.score)}</td>#{show_user ? "<td>#{small_avatar(s.user)}#{a(h(s.user.name), :href => "/users/#{s.user.id}")}</td>" : ''}<td class='last_r score_when' rel='#{s.when.to_i * 1000}'>#{nice_date_time s.when}</td></tr>"
=begin
        attrs = {}
        attrs[:class] = 'last_b' if s == scores.last
        tr(attrs) do
          td.score { number_with_delimiter s.score }
          td { small_avatar(s.user) + a(h(s.user.name), :href => "/users/#{s.user.id}").to_s } if show_user
          text "<td class='last_r score_when' rel='#{s.when.to_i * 1000}'>#{nice_date_time s.when}</td>"
        end
=end
      end
    end
  end

  def _scores_by_users(users)
    table.scores do
      tr do
        th { "Avg. score" }
        th { "Username" }
        th.last_r { "Last active" }
      end

      users.each do |u|
        text "<tr#{u == users.last ? ' class=\'last_b\'' : ''}><td>#{number_with_delimiter(u.high_score)}</td><td>#{small_avatar(u)}#{a(h(u.name), :href => "/users/#{u.id}")}</td><td class='last_r score_when' rel='#{u.latest_score.when.to_i * 1000}'>#{nice_date_time u.latest_score.when}</td>"
=begin
        attrs = {}
        attrs[:class] = 'last_b' if u == users.last
        tr(attrs) do
          td.score { number_with_delimiter(u.high_score) }
          #puts "dss: #{'' + a(h(u.name), :href => "/users/#{u.id}")}"
          #puts "dss: #{(small_avatar(u) + a(h(u.name), :href => "/users/#{u.id}")).class}"
          td { small_avatar(u) + a(h(u.name), :href => "/users/#{u.id}").to_s }
          text "<td class='last_r score_when' rel='#{u.scores_when.to_i * 1000}'>#{nice_date_time u.scores_when}</td>"
        end
=end
      end
    end
  end
end

def Akc.create
  Akc::Models.create_schema
  ActiveRecord::Base.default_timezone = :utc

=begin
  ActiveRecord::Base.connection.execute("ALTER TABLE akc_users ADD COLUMN top_score_id INT")
  ActiveRecord::Base.connection.execute("ALTER TABLE akc_users ADD COLUMN latest_score_id INT")
  Akc::Models::User.find(:all).each do |u|
    u.top_score_id = u.scores.find(:first, :order => 'score DESC').id
    u.latest_score_id = u.scores.find(:first, :order => 'akc_scores.when DESC').id
    u.save
  end
=end
end