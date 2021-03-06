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
              p { "&copy; 2009-#{Date.today.year} Brenton Fletcher. Check out <a href=\"http://blog.bloople.net\">my blog</a>. Comments? <a href=\"mailto:i@bloople.net\">i@bloople.net</a>. Made on a Mac with Camping." }
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
      _scores_by_users(@users, true)
      h2 { "Top 3 Individual High Scores" }
      _scores(@scores, true, true)
      h2 { "Top 3 Users by Number of Scores Submitted" }
      table.scores do
        tr do
          th { "Rank" }
          th { "No. submitted" }
          th { "Username" }
          th.last_r { "Last active" }
        end

        @users_by_scores_submitted.each_with_index do |u, i|
          last_active = u.latest_score.when
          
          attrs = {}
          attrs['class'] = 'last_b' if u == @users_by_scores_submitted.last
          tr attrs do
            td { i + 1 }
            td.score { number_with_delimiter(u.scores.count) }
            td { tag!(:a, :href => "/users/#{u.id}") { small_avatar(u) + wbrize(u.name) } }
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
      p { "This page is cached, and so may not include data from the last 10 minutes." }
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
      p { "ArrowKeyControl is a fast-paced game for the Apple Dashboard that tests your speed." }
      p { "The idea is simple - the game shows an arrow, and you have to hit the corresponding arrow key; get it right, and you go again; get it wrong, or hit the key too slowly, and it's game over. Did I mention you have to keep getting faster all the time?" }
      p { "The faster you are, the more you score. Your scores are automatically submited to this web site, so you can compare scores with other players." }
      h2 { "How to Play" }
      ol do
        li { "To begin a game, click the Play button on the widget. You will have 1.5 seconds to get ready." }
        li { "The widget will then display an arrow. You have to hit the corresponding arrow key as fast as possible - you've got 1 second to hit the first key." }
        li { "While the game is showing the arrow, the background of the game fills from left to right in red - this shows how much time you have left to hit the key; if this fills up before you hit the key, the game ends." }
        li { "The faster you press the correct key, the more you score. The game then displays another arrow key (sometimes the same one as the last one), and reduces the amount of time you have to hit the next key (so you have to get faster!)." }
        li { "This continues until you aren't fast enough to keep up with the computer, or you hit the wrong key." }
      end
      h2 { "How to get ArrowKeyControl" }
      p { "ArrowKeyControl is an Apple Dashboard widget; simply follow the intructions below to start playing." }
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

    @content_for[:head] = capture(true) do
      link :href => '/high_scores_absolute.rss', :rel => 'alternate', :title => 'RSS feed of individual high scores', :type => 'application/rss+xml'
      link :href => '/high_scores_average.rss', :rel => 'alternate', :title => 'RSS feed of averaged high scores', :type => 'application/rss+xml'
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
      p { tag!(:a, :href => "/users/#{@user.id}/all_scores") { 'All of ' + wbrize(@user.name) + '\'s scores' } }
      p { a('RSS feed for top scores', :href => "/users/#{@user.id}/high_scores.rss") }
    end

    div.user_show_col_middle do
      h3 { "Latest 10 scores" }
      _scores(@latest_scores, false)
      p { tag!(:a, :href => "/users/#{@user.id}/all_scores") { 'All of ' + wbrize(@user.name) + '\'s scores' } }
      p { a('RSS feed for latest scores', :href => "/users/#{@user.id}/latest_scores.rss") }
    end

    div.user_show_col_left do
      h3 { "Summary" }
      table do
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
    p { "This page is cached, and so may not include data from the last 10 minutes." }
    div.col_right do
      h2 { "Top 1000 Individual High Scores" }
      _scores(@scores, true, true)
      p { a('RSS feed of individual high scores', :href => '/high_scores_absolute.rss') }
    end
    div.col_left do
      h2 { "Top 1000 Averaged High Scores" }
      _scores_by_users(@users, true)
      p { a('RSS feed of averaged high scores', :href => '/high_scores_average.rss') }
    end

    div.clear { " " }

    p.utc! { "Note: all dates are in <acronym title=\"Greenwich Mean Time\">GMT</acronym> / <acronym title=\"Coordinated Universal Time\">UTC</acronym>." }
    p.local! { "Note: all dates are in your local time." }
  end

  def statistics
    h2 { "Statistics" }
    p { "These graphs are cached, and so may not include data from the last 10 minutes." }
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
    @headers['Content-Type'] = 'application/rss+xml; charset=UTF-8'
    instruct! :xml, :version => '1.0'
    rss(:version => '2.0') do
      channel do
        title "Top 50 individual scores"
        description "Top 50 individual scores"
        link "http://akc.bloople.net/"
        for s in @scores
          item do
            title "#{s.user.name} scored #{number_with_delimiter s.score} at #{nice_date_time s.when}"
            description "#{s.user.name} scored #{number_with_delimiter s.score} at #{nice_date_time s.when} UTC."
            pubDate s.when.to_s(:rfc822)
            link("http://akc.bloople.net/users/#{s.user.id}")
          end
        end
      end
    end
  end

  def high_scores_average
    @render_layout = false
    @headers['Content-Type'] = 'application/rss+xml; charset=UTF-8'
    instruct! :xml, :version => '1.0'
    rss(:version => '2.0') do
      channel do
        title "Top 50 averaged high scores"
        description "Top 50 averaged high scores"
        link "http://akc.bloople.net/"
        for u in @users
          item do
            title "#{u.name} has an averaged high score of #{number_with_delimiter u.high_score}"
            description "#{u.name} has an average of #{number_with_delimiter u.high_score} over their last 100 scores, or if they have less than 100 scores submitted, the average of all their scores. #{u.name}'s latest score was submitted at #{nice_date_time u.latest_score.when} UTC."
            pubDate u.latest_score.when.to_s(:rfc822)
            link("http://akc.bloople.net/users/#{u.id}")
          end
        end
      end
    end
  end

  def latest_scores_by_user
    @render_layout = false
    @headers['Content-Type'] = 'application/rss+xml; charset=UTF-8'
    instruct! :xml, :version => '1.0'
    rss(:version => '2.0') do
      channel do
       title "Latest 50 scores for #{@user.name}"
       description "Latest 50 scores for #{@user.name}"
       link "http://akc.bloople.net/"
        for s in @scores
          item do
            title "#{number_with_delimiter s.score} at #{nice_date_time s.when}"
            description "#{@user.name} scored #{number_with_delimiter s.score} at #{nice_date_time s.when} UTC."
            pubDate s.when.to_s(:rfc822)
            link("http://akc.bloople.net/users/#{@user.id}")
          end
        end
      end
    end
  end

  def high_scores_by_user
    @render_layout = false
    @headers['Content-Type'] = 'application/rss+xml; charset=UTF-8'
    instruct! :xml, :version => '1.0'
    rss(:version => '2.0') do
      channel do
       title "Top 50 scores for #{@user.name}"
       description "Top 50 scores for #{@user.name}"
       link "http://akc.bloople.net/"
        for s in @scores
          item do
            title "#{number_with_delimiter s.score} at #{nice_date_time s.when}"
            description "#{@user.name} scored #{number_with_delimiter s.score} at #{nice_date_time s.when} UTC."
            pubDate s.when.to_s(:rfc822)
            link("http://akc.bloople.net/users/#{@user.id}")
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

    p { "Note that shoutbox messages will take up to 10 minutes to appear." }
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

  def _scores(scores, show_user, show_rank = false)
    table.scores do
      tr do
        th { "Rank" } if show_rank
        th { "Score" }
        th { "Username" } if show_user
        th.last_r { "When" }
      end

      scores.each_with_index do |s, i|
        text "<tr#{s == scores.last ? ' class=\'last_b\'' : ''}>#{show_rank ? "<td>#{i + 1}</td>" : ""}<td>#{number_with_delimiter(s.score)}</td>#{show_user ? "<td>#{small_avatar(s.user)}#{a(:href => "/users/#{s.user.id}") { wbrize(s.user.name) }}</td>" : ''}<td class='last_r score_when' rel='#{s.when.to_i * 1000}'>#{nice_date_time s.when}</td></tr>"
      end
    end
  end

  def _scores_by_users(users, show_rank = false)
    table.scores do
      tr do
        th { "Rank" } if show_rank
        th { "Average" }
        th { "Username" }
        th.last_r { "Last active" }
      end

      users.each_with_index do |u, i|
        text "<tr#{u == users.last ? ' class=\'last_b\'' : ''}>#{show_rank ? "<td>#{i + 1}</td>" : ""}<td>#{number_with_delimiter(u.high_score)}</td><td>#{small_avatar(u)}#{a(:href => "/users/#{u.id}") { wbrize(u.name) }}</td><td class='last_r score_when' rel='#{u.latest_score.when.to_i * 1000}'>#{nice_date_time u.latest_score.when}</td></tr>"
      end
    end
  end

  def invalid_crypt
    h2 { "Your username or password is incorrect" }
    p { "Please check your username and password and play again." }
  end





  def oz_quiz_released
    h2 { "Oz Quiz released" }
    div(:class => "screenshot oz_quiz_screenshot") do
      img :src => '/images/oz_quiz_released/screenshot.jpg'
      text "Oz Quiz in action"
    end
    p { "Hello, #{@user.name}. I'd like a couple minutes of your time to tell you about a new iPhone application I (the developer of ArrowKeyControl) have released." }
    p { "<a href='http://itunes.com/apps/ozquiz'>Oz Quiz</a> is a quiz application with more than 600 carefully researched questions on all aspects of Australian history, politics, popular culture, our indigenous people, environment, technology, arts, music, sport, geography, law, demography and more." }
    p { "Oz Quiz also has <a href='http://ozquiz.brentonfletcher.com/'>internet scoring</a>, as well as personalised user pages to show your quiz scores." }
    p { "Oz Quiz is available for the iPhone and iPod Touch, and is <a href='http://itunes.com/apps/ozquiz'>on sale</a> for $2.49 Australian (or $1.99 US) 'til Australia Day, so check it out soon." }
    h3 { "What is this message?" }
    p { "Very occasionally, I put out messages like this one to tell ArrowKeyControl users about major changes to ArrowKeyControl, the ArrowKeyControl website, or if I am releassing a new project I think you might like. You can stop these messages for ever appearing by clicking the 'i' or 's' button in the lower-right-hand corner of the ArrowKeyControl widget and unchecking 'Internet Scoring'." }
    div.clear { " " }
  end
end
