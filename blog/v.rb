module Blog::Views
  def layout
    xhtml11 do
      head do
        meta :'http-equiv' => 'Content-Type', :content => 'text/html; charset=utf-8'
        title "Coderplay #{' - ' + @title if @title}"
        link :rel => 'stylesheet', :type => 'text/css', :href => '/style.css'
        link :rel => 'alternate', :type => 'application/rss+xml', :href => "/rss#{"/#@tag" if @tag != 'Index'}"
        link :rel => 'shortcut icon', :type => 'image/x-icon', :href => '/murfy32.png'
      end
      body do
        div.wrap! do
          div.header! do
            h1 do
              a(:href => R(Index), :accesskey => 'I') { span "Coderplay" }
            end
            h2 do
              "Like a truck through a plate glass window, Brenton Fletcher is comin' at you with more code than you can handle."
            end
          end
          div.sidebar! do
            h2.first 'Tags'
            p { "Use the links below to browse my past works." }
            p { tags.sort.map { |t| a t, :href => self / "/tag/#{t}" }.join("&nbsp; ") }
            h2 'Search'
            form :action => '/search', :method => :post do
              input :type => :text, :name => :query, :value => @search_query || ''
              input :type => :submit, :class => :submit, :value => 'Search'
            end
            h2 'About me'
            img(:src => '/images/me.jpg')
            p { "I currently hold the position of Ruby on Rails developer with the award-winning <a href='http://www.katalyst.com.au'>Katalyst Web Design</a> in Adelaide, SA, Australia. My work has been mentioned in the media several times, <a href='/tag/Media'>click here</a> to see them all." }
            p { "You can email me at <a href='mailto:&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;'>&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;</a>." }
            p { a('More...', :href => '/read/about') }
            h2 'Recent comments'
            Blog::Models::Comment.find(:all, :order => 'created_at DESC', :limit => 5).each do |c|
              h4 { a(ellipsis(c.body), :href => R(Read, c.post.id) + "#comment-#{c.id}") + " on " + a(c.post.title, :href => R(Read, c.post.id)) }
            end
            #h2 'Twitter posts'
            #text '<script id="feed-1250996587956855" type="text/javascript" src="http://rss.bloople.net/?url=http%3A%2F%2Ftwitter.com%2Fstatuses%2Fuser_timeline%2F15440326.rss&detail=-1&limit=5&showtitle=false&type=js&id=1250996587956855"></script>'
            p { a('More...', :href => 'http://twitter.com/bloopletech') }
            h2 'Last.fm feed'
            text '<script id="feed-1251529262816519" type="text/javascript" src="http://rss.bloople.net/?url=http%3A%2F%2Fws.audioscrobbler.com%2F1.0%2Fuser%2Fbloopletech%2Frecenttracks.rss&detail=-1&limit=5&showtitle=false&type=js&id=1251529262816519"></script>'
            p { a('More...', :href => 'http://www.last.fm/user/bloopletech') }
          end
          div.content! do
            menu[:top][:visitor] = []
            menu[:top][:admin] << a('New', :href => self / "/new#{"/#@tag" if @tag != 'Index'}") if logged_in?
            menu[:top][:admin] << a('Assets', :href => "/assets") if logged_in?
            menu[:top][:admin] << 'Logout' if logged_in?
            div.bar! { menu :top } if logged_in?

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

          div.clear { "" }

          div.footer! { "&copy; 2008-#{Date.today.year} #{a "Brenton Fletcher", :href => "http://i.bloople.net"}. <a href='mailto:&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;'>Email me</a>! Made on a #{a "Mac", :href => "http://apple.com"}. Powered by #{a "Ruby", :href => "http://ruby-lang.org"} on #{a "blokk #{VERSION}", :href => 'http://murfy.de/read/blokk'} (modified) on Camping." }
        end
      end
    end
  end
  
  def index
    _index_archive_header

    if @posts.empty?
      p 'No posts yet.'
    else
      div.post do
        p { a('Older posts', :href => "/archive/#{@tag}/1") }
      end if @has_older_pages
      @posts.each { |post| _post post }
      div.post do
        p { a('Older posts', :href => "/archive/#{@tag}/1") }
      end if @has_older_pages
    end
  end
  
  def archive
    _index_archive_header

    links = []
    links << a('Older posts', :href => "/archive/#{@tag}/#{@page + 1}") if @has_older_posts
    links << a('Newer posts', :href => (@has_newer_posts ? "/archive/#{@tag}/#{@page - 1}" : "/"))
    p.pagination { links.join(' | ') }

    @posts.each { |post| _post post }

    p.pagination { links.join(' | ') }
  end

  def search
    h2.breaker { "All posts containing '#{h @search_query}'" }#"#{@total_pages > 1 ? ", page #{(@page || 0) + 1} of #{@total_pages}" : ""}"}

#      links = []
#      links << a('Older posts', :href => "/search/#{@tag}/#{@page + 1}") if @has_older_posts
#      links << a('Newer posts', :href => (@has_newer_posts ? "/archive/#{@tag}/#{@page - 1}" : "/"))
#      p.pagination { links.join(' | ') }

    if @posts.empty?
      p 'No posts match your search query.'
    else
      @posts.each { |post| _post post }
    end

#      p.pagination { links.join(' | ') }
  end
  
  def login
    logged_in? ? yield : _login_form
  end
  
  def new
    login { _post_form @post, R(New) }
  end
  
  def edit
    login { _post_form @post, R(Edit) }
  end
  
  def delete
    login do
      p { text 'Really delete %s?' % a(@post.title, :href => R(Read, @post.id)) }
      form :action => R(Delete), :method => :post do
        input :type => :hidden, :name => :id, :value => @post.id
        input :type => :submit, :class => :submit, :value => 'Delete'
      end
    end
  end
  
  def view
    @title = @post.title
    _post @post, true
    
    # comments
    h2 'Say something!'
    @post.comments.each do |c|
      div(:class => "comment", :id => "comment-#{c.id}") do
        p.body c.body
        timestamp = nice_date_time(c.created_at)
        p.username "#{c.username} @ #{timestamp}"
        a 'Delete', :href => R(Shoot, c), :onclick => "return confirm('Sure?');" if logged_in?
      end
    end
    
    form :action => R(Read, @post), :method => :post do
      div do
        label_for :Name, @comment, :username, :accesskey => 'C'
        input.name! :name => :name, :value => @comment.username, :size => 41, :type => :text
      end
      div do
        label_for :Comment, @comment, :body
        textarea.comment! @comment.body, :name => :comment, :cols => 60, :rows => 10
        input.bot! :type => :hidden, :name => :bot, :value => 'spambot'
        input :type => :submit, :class => :submit, :value => 'OK', :onclick => "getElementById('bot').value='K'"
      end
      # Later: Textile
      a 'use Textile', :href => 'http://whytheluckystiff.net/ruby/redcloth', :target => '0' if false
    end
  end

  def assets
    form :action => '/assets', :method => 'post', :enctype => 'multipart/form-data' do
      div do
        label_for :upload
        input :type => :file, :name => :upload
      end
      div do
# b         label_for :filename
#          input :type => :text, :name => :fn, :value => "#{Time.now.to_i}_#{rand(999999)}"
        input :type => :submit, :class => :submit, :value => 'Add'
      end
    end

    Dir.glob("#{PATH}/public/assets/*_small.jpg") do |filename|
      div.asset do
        fn = "#{filename.gsub(/^#{Regexp.escape(PATH)}\/public/, '')}"
        img :src => fn
        text "#{fn} "
        a 'Delete', :href => "/assets/delete/#{fn.gsub(/^\/assets\//, '').gsub(/_small.jpg$/, '.jpg')}", :onclick => "return confirm('Sure?');"
      end
    end
    
    div.clear {}
  end
      
  
  # Partials
  def _post post, full = false
    div.post do
      h2 { a post.title, :href => R(Read, post.nickname) }
      excerpt, body = *post.body.split(/^---+/, 2)
      div.body { text RedCloth.new("#{excerpt}#{body if full}").to_html }
      p.subtitle do
        text "#{nice_date_time(post.created_at)}"
      end
      cs = post.comments.size
      
      menu[id = post.nickname || post.id][:visitor] << "Tagged with #{post.tags.scan(/[-\w]+/).map { |t| a t, :href => R(Index, t) }.join(' ')}, #{cs} comment#{'s' unless cs == 1}"
      menu[id][:visitor] << a('Comments', :href => R(Read, id)) unless full
      menu[id][:admin] << a('Edit', :href => R(Edit, id), :accesskey => ('E' if full)) if logged_in?
      menu[id][:admin] << 'Delete' if logged_in?
      menu id
    end
  end
  
  def _login_form
    form :action => R(Login), :method => :post do
      div do
        label_for :name
        input :name => :name, :type => :text
      end
      div do
        label_for :password
        input :name => :password, :type => :password
        input :type => :submit, :class => "submit", :name => :login, :value => 'Login'
      end
    end
  end
  
  def _post_form post, action
    form :method => :post, :action => action do
      div do
        label_for :title, post
        input.title! :name => :title, :type => :text, :size => 81, :value => post.title
      end
      div do
        label_for :body, post
        textarea.body! post.body, :name => :body, :cols => 80, :rows => 30, :accesskey => 'B'
      end
      div do
        label_for :nickname, post
        input.nickname! :name => :nickname, :type => :text, :size => 81, :value => post.nickname
        label_for :tags, post, :accesskey => 'T'
        input.tags! :name => :tags, :type => :text, :size => 81, :value => post.tags
        input :type => :hidden, :name => :id, :value => post.id
        input :type => :submit, :class => "submit", :value => 'Save', :accesskey => 'S'
      end
    end
  end

  def _index_archive_header
    h2.breaker "All posts#{@tag && @tag != "Index" ? " tagged with #{@tag}" : ""}#{@total_pages > 1 ? ", page #{(@page || 0) + 1} of #{@total_pages}" : ""}"
  end
  
end