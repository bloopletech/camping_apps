module Akc::Controllers
  class CheckOutAkc < R '/check_out_akc/(\d+)'
    def get(id)
      @user = User.find(id)
      render :check_out_akc
    end
  end

  class OzQuizReleased < R '/oz_quiz_released/(\d+)'
    def get(id)
      @user = User.find(id)
      render :oz_quiz_released
    end
  end

  class Index < R '/'
    @cacheable = true

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

  class AddScore < R '/add/(.*?)/(\d+)/(.*?)/(.*?)/(\d+)'
    def get(source, version, name, crypt, score)
      source = CGI.unescape(source).gsub(/ +/, ' ')
      name = CGI.unescape(name).gsub(/ +/, ' ')
      crypt = CGI.unescape(crypt).gsub(/ +/, ' ')

      User.transaction do
        source = (source == '' ? 'dashboard' : source)

        user = User.find_by_name(name)
        if user
          unless user.crypt == crypt
            return mab { text "0|http://akc.bloople.net/invalid_crypt" }
          end
        else
          user = User.create(:name => name, :crypt => crypt, :seen_oz_quiz_released => true)
        end

        Score.create(:version => version, :user => user, :score => score, :when => Time.now, :source => source)

        #if !user.seen_oz_quiz_released?
        #  user.seen_oz_quiz_released = true
        #  user.save!
        #  return mab { text "0|http://akc.bloople.net/oz_quiz_released/#{user.id}" }
        #else
          return mab { text "" }
        #end
      end
    end
  end
  
  class HighScores < R '/high_scores'
    @cacheable = true

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
    @cacheable = true

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
    @cacheable = true

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
      @shout = Shout.new(:username => input.username, :text => input.text, :captcha => input.captcha, :posted => Time.now.getgm)
      if @shout.save
        add_success("Your shout has been published; it may take up to 10 minutes for your shout to be visible to other people.")
      else
        @shout.errors.full_messages.each { |msg| add_error(msg) }
      end
      redirect '/'
    end
  end

  class InvalidCrypt < R '/invalid_crypt'
    def get
      render :invalid_crypt
    end
  end

  include StaticAssetsClass
end