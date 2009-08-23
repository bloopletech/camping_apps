# encoding: utf-8

%w(redcloth camping/ar camping/session image_science lib/common).each { |lib| require lib }

# Fix unicode urls
$KCODE = 'u'

Camping.goes :Blog

# TODO: safe Textile for comments
# TODO: fix Textile (produces improper HTML at times, < for example)
# TODO: document
# DONE: the whole title is one single link
# DONE: RSS feed link links to current tag.
# DONE: RSS feed is served with correct Content-Type.
# DONE: RSS feed converts Textile to HTML.
# DONE: RSS feed has an image now.
module Blog; VERSION = 0.99
  PATH = File.expand_path(File.dirname(__FILE__)) + '/blog'

  include Camping::Session
  def service(*a)
    # Don't set any cookies unless necessary
    
    #def @cookies.[]=(k,v); end unless @env.PATH_INFO == self / '/login'
    super(*a)
  end
  
  module Models
    
    class CreateTheBasics < V 1.0
      def self.up
        create_table :blog_admins, :force => true do |table|
          table.string :name, :password
        end
        print "Password for #{user = ENV['USER']}? "
        Admin.create :name => user, :password => $stdin.gets.chomp
        
        create_table :blog_posts, :force => true do |table|
          table.string :title, :tags, :nickname
          table.text :body
          table.timestamps
        end
        
        create_table :blog_comments, :force => true do |table|
          table.integer :post_id
          table.string :username
          table.text :body
          table.datetime :created_at
        end
      end
    end
    
    class Admin < Base; end
    
    class Post < Base
      has_many :comments, :order => 'created_at ASC'
      validates_presence_of :title, :nickname
      validates_uniqueness_of :nickname
    end
    
    class Comment < Base
      validates_presence_of :username
      validates_length_of :body, :within => 1..3000
      validates_inclusion_of :bot, :in => %w(K)
      validates_associated :post
      belongs_to :post
      attr_accessor :bot
    end
    
  end
  
  def self.create
    Blog::Models.create_schema :assume => (Blog::Models::Post.table_exists? ? 1.0 : 0.0)
    ActiveRecord::Base.default_timezone = :utc
  end
  
  module Helpers
    
    # login system
    def current_user
      @current_user ||= Models::Admin.find(@state.admin_id) unless @state.admin_id.blank?
    end
    alias logged_in? current_user
    
    def login name, password
      @current_user = Models::Admin.find_by_name_and_password input.name, input.password
      puts "current_user: #{@current_user.inspect}"
      @state.admin_id = @current_user.id if @current_user
    end
    
    def logout
      @state.admin_id = nil
    end
    
    # menu bar
    def menu target = nil
      if target
        args = target.is_a?(Symbol) ? [] : [target]
        for role, submenu in menu[target].sort_by { |k, v| [:visitor, :admin].index k }
          ul.menu.send(role) do
            submenu.each do |x|
              liopts = (x == submenu.last) ? { :class => 'last' } : { }
              li(liopts) { x[/\A\w+\z/] ? a(x, :href => R(Controllers.const_get(x), *args)) : x }
            end
          end unless submenu.empty?
        end
      else
        @menu ||= Hash.new { |h, k| h[k] = { :visitor => [], :admin => [] } }
      end
    end
    
    # shortcut for error-aware labels
    def label_for name, record = nil, attr = name, options = {}
      errors = record && !record.body.blank? && !record.valid? && record.errors.on(attr)
      label name.to_s, { :for => name }, options.merge(errors ? { :class => :error } : {})
    end
    
    # find all tags
    def tags
      Models::Post.find(:all, :select => 'DISTINCT tags').map(&:tags).join(' ').split(/\s+/).uniq
    end
    
  end
  
  # beautiful XHTML 11
  class Mab
    def xhtml11(&block)
      self.tagset = Markaby::XHTMLStrict
      declare! :DOCTYPE, :html, :PUBLIC, '-//W3C//DTD XHTML 1.1//EN', 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'
      tag!(:html, :xmlns => 'http://www.w3.org/1999/xhtml', 'xml:lang' => 'en', &block)
      self
    end
  end
  
  module Controllers
    
    class Index < R '/', '/index', '/tag/()([-\w]*)', '/all()()', '/(rss)', '/(rss)/([-\w]+)'
      def get format = 'html', tag = 'Index'
        conditions = tag ? { :conditions => "tags LIKE '%#{@tag = tag}%'" } : {}
        @has_older_pages = Post.count(:all, conditions) > 5
        standard_conds = { :order => 'created_at DESC' }
        standard_conds[:limit] = 5 if format == 'html' or format == ''
        @posts = Post.find :all, conditions.merge(standard_conds)
        if format == 'rss'
           rss = ::RSS.feed :title => 'Coderplay', :about => 'http://blog.bloople.net/rss',
            :link => 'http://blog.bloople.net/', :description => 'Personal blog of Brenton Fletcher' do |feed|
            for post in @posts
              feed.item :title => post.title, :link => URL(Read, post.nickname).to_s,
                :date => post.created_at,
                :description => RedCloth.new("#{post.body.split(/^---+/, 2).first}").to_html
            end
          end
          r(200, rss.to_s, 'Content-Type' => 'application/rss+xml; charset=UTF-8')
        else
          render :index
        end
      end
    end

    class Archive < R '/archive/([-\w]*)/(\d+)'
      def get(tag, page)
        @tag = tag
        @page = page.to_i
        count = Post.count :all, :conditions => "tags LIKE '%#{@tag}%'"
        start = (@page * 5)
        @has_older_posts = (start + 5) < count
        @has_newer_posts = @page > 1
        @posts = Post.find :all, :conditions => "tags LIKE '%#{@tag}%'", :order => 'created_at DESC', :limit => 5, :offset => start
        render :archive
      end
    end
    
    class New < R '/new', '/new/([-\w]*)'
      def get tag = nil
        @post = Post.new :tags => "Index #{tag}".strip if logged_in?
        render :new
      end
      def post
        return unless logged_in?
        @post = Post.create :title => input.title, :nickname => input.nickname, :tags => input.tags, :body => input.body
        if @post.valid?
          redirect Read, @post.nickname
        else
          render :new
        end
      end
    end
    
    class Edit < R '/edit/([-\w]+)', '/edit'
      def get id
        @post = Post.find :first, :conditions => ['id = ? OR nickname = ?', id, id] if logged_in?
        render :edit
      end
      
      def post
        return unless logged_in?
        @post = Post.find input['id']
        @post.update_attributes :title => input.title, :body => input.body, :tags => input.tags, :nickname => input.nickname
        if @post.valid?
          redirect Read, @post.nickname
        else
          render :edit
        end
      end
    end
    
    class Delete < R '/delete/([-\w]+)', '/delete'
      def get id
        @post = Post.find :first, :conditions => ['id = ? OR nickname = ?', id, id] if logged_in?
        render :delete
      end
      def post
        (@post = Post.find(input[:id])).destroy if logged_in?
        redirect Index
      end
    end
    
    class Shoot < R '/shoot/(\d+)'
      def get comment_id
        return unless logged_in?
        (comment = Comment.find(comment_id)).destroy
        redirect Read, comment.post_id
      end
    end

    class ManageAssets < R '/assets'
      def get
        #return unless logged_in?
        render :assets
      end
      def post
        #return unless logged_in?

        #puts "env: #{@env.inspect}"
        #puts "params: #{@request.params.inspect}"
        #puts "input: #{input.inspect}"
        #puts "filename: #{input.fn.inspect}"
        #puts "upload: #{input.upload.inspect}"
        puts "tempfile: #{input.upload[:tempfile].inspect}"
        puts "path: #{input.upload[:tempfile].path}"
        puts "PATH: #{PATH}"

        fn = "#{Time.now.to_i}_#{rand(999999)}"
        #puts IO.readlines(input.upload[:tempfile].path).join("\n")
        puts "path: #{PATH}/public/assets/#{fn}.jpg"
        ImageScience.with_image(input.upload[:tempfile].path) do |img|
          img.thumbnail(1000) { |thumb| thumb.save("#{PATH}/public/assets/#{fn}.jpg") }
          img.thumbnail(400) { |thumb| thumb.save("#{PATH}/public/assets/#{fn}_small.jpg") }
        end
        
        redirect "/assets"
      end
    end
    
    class DeleteAsset < R '/assets/delete/(.+)'
      def get filename
        return unless logged_in?
        File.delete("#{PATH}/public/assets/#{filename}")
        File.delete("#{PATH}/public/assets/#{filename.gsub(/\.jpg$/, '')}_small.jpg")
        redirect "/assets"
      end
    end
    
    class Assets < R '/assets/(.+)'
      MIME_TYPES = { '.css' => 'text/css', '.js' => 'text/javascript', '.jpg' => 'image/jpeg'}

      def get(path)
        @headers['Content-Type'] = MIME_TYPES[path[/\.\w+$/, 0]] || "text/plain"
        unless path.include? ".." # prevent directory traversal attacks
          @headers['X-Sendfile'] = "#{PATH}/public/assets/#{path}"
        else
          @status = "403"
          "403 - Invalid path"
        end
      end
    end

    include StaticAssetsClass
    
    class Login < R '/login', '/logout'
      def post
        login input.username, input.password
        logged_in? ? redirect(Index) : get
      end
      def get
        logout
        render :login
      end
    end
    
    Logout = Login
    
    # Lowest precedence to allow urls like /<nickname>
    class Read < R '/read/([-\w]+)', '/([-\w]+)'
      def get id
        @post = Post.find :first, :conditions => ['id = ? OR nickname = ?', id, id]
        @comment = Comment.new :body => input.comment, :username => input.name
        render :view if @post
      end
      def post id
        @comment = Comment.create :post_id => id, :bot => input.bot,
          :username => (name = input.name), :body => (comment = input.comment)
        redirect self / "/read/#{id}?name=#{CGI::escape name}&comment=#{CGI::escape comment}"
      end
    end
  end
  
  module Views
    
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
              div.logo! do
                h1 do
                  a(:href => R(Index), :accesskey => 'I') { span "Coderplay" }
                end
              end
            end
            div.sidebar! do
              h2.first 'Tags'
              p { tags.sort.map { |t| a t, :href => self / "/tag/#{t}" }.join("&nbsp; ") }
              h2 'About me'
              img(:src => '/images/me.jpg')
              p { "I currently hold the position of Ruby on Rails developer with the award-winning <a href='http://www.katalyst.com.au'>Katalyst Web Design</a> in Adelaide, SA, Australia. My work has been mentioned in the media several times, <a href='/tag/Media'>click here</a> to see them all." }
              p { a('More...', :href => '/read/about') }
              h2 'Twitter posts'
              text '<script id="feed-1250996587956855" type="text/javascript" src="http://rss.bloople.net/?url=http%3A%2F%2Ftwitter.com%2Fstatuses%2Fuser_timeline%2F15440326.rss&detail=-1&limit=5&showtitle=false&type=js&id=1250996587956855"></script>'
              p { a('More...', :href => 'http://twitter.com/bloopletech') }
              h2 'Last.fm feed'
              text "<div class=\"badge\"><style type=\"text/css\">table.lfmWidgetchart_821f77321b90c94f61be2fbbddf9dd5e td {margin:0 !important;padding:0 !important;border:0 !important;}table.lfmWidgetchart_821f77321b90c94f61be2fbbddf9dd5e tr.lfmHead a:hover {background:url(http://cdn.last.fm/widgets/images/en/header/chart/recenttracks_regular_black.png) no-repeat 0 0 !important;}table.lfmWidgetchart_821f77321b90c94f61be2fbbddf9dd5e tr.lfmEmbed object {float:left;}table.lfmWidgetchart_821f77321b90c94f61be2fbbddf9dd5e tr.lfmFoot td.lfmConfig a:hover {background:url(http://cdn.last.fm/widgets/images/en/footer/black.png) no-repeat 0px 0 !important;;}table.lfmWidgetchart_821f77321b90c94f61be2fbbddf9dd5e tr.lfmFoot td.lfmView a:hover {background:url(http://cdn.last.fm/widgets/images/en/footer/black.png) no-repeat -85px 0 !important;}table.lfmWidgetchart_821f77321b90c94f61be2fbbddf9dd5e tr.lfmFoot td.lfmPopup a:hover {background:url(http://cdn.last.fm/widgets/images/en/footer/black.png) no-repeat -159px 0 !important;}</style>              <table class=\"lfmWidgetchart_821f77321b90c94f61be2fbbddf9dd5e\" cellpadding=\"0\" cellspacing=\"0\" border=\"0\" style=\"width:184px;\"><tr class=\"lfmHead\"><td><a title=\"bloopletech: Recently Listened Tracks\" href=\"http://www.last.fm/user/bloopletech\" target=\"_blank\" style=\"display:block;overflow:hidden;height:20px;width:184px;background:url(http://cdn.last.fm/widgets/images/en/header/chart/recenttracks_regular_black.png) no-repeat 0 -20px;text-decoration:none;border:0;\"></a></td></tr><tr class=\"lfmEmbed\"><td><object type=\"application/x-shockwave-flash\" data=\"http://cdn.last.fm/widgets/chart/19.swf\" codebase=\"http://download.macromedia.com/pub/shockwave/cabs/flash/swflash.cab#version=7,0,0,0\" id=\"lfmEmbed_28629697\" width=\"184\" height=\"179\"> <param name=\"movie\" value=\"http://cdn.last.fm/widgets/chart/19.swf\" /> <param name=\"flashvars\" value=\"type=recenttracks&amp;user=bloopletech&amp;theme=black&amp;lang=en&amp;widget_id=chart_821f77321b90c94f61be2fbbddf9dd5e\" /> <param name=\"allowScriptAccess\" value=\"always\" /> <param name=\"allowNetworking\" value=\"all\" /> <param name=\"allowFullScreen\" value=\"true\" /> <param name=\"quality\" value=\"high\" /> <param name=\"bgcolor\" value=\"000000\" /> <param name=\"wmode\" value=\"transparent\" /> <param name=\"menu\" value=\"true\" /> </object></td></tr><tr class=\"lfmFoot\"><td style=\"background:url(http://cdn.last.fm/widgets/images/footer_bg/black.png) repeat-x 0 0;text-align:right;\"><table cellspacing=\"0\" cellpadding=\"0\" border=\"0\" style=\"width:184px;\"><tr><td class=\"lfmConfig\"><a href=\"http://www.last.fm/widgets/?colour=black&amp;chartType=recenttracks&amp;user=bloopletech&amp;chartFriends=0&amp;from=code&amp;widget=chart\" title=\"Get your own widget\" target=\"_blank\" style=\"display:block;overflow:hidden;width:85px;height:20px;float:right;background:url(http://cdn.last.fm/widgets/images/en/footer/black.png) no-repeat 0px -20px;text-decoration:none;border:0;\"></a></td><td class=\"lfmView\" style=\"width:74px;\"><a href=\"http://www.last.fm/user/bloopletech\" title=\"View bloopletech's profile\" target=\"_blank\" style=\"display:block;overflow:hidden;width:74px;height:20px;background:url(http://cdn.last.fm/widgets/images/en/footer/black.png) no-repeat -85px -20px;text-decoration:none;border:0;\"></a></td><td class=\"lfmPopup\"style=\"width:25px;\"><a href=\"http://www.last.fm/widgets/popup/?colour=black&amp;chartType=recenttracks&amp;user=bloopletech&amp;chartFriends=0&amp;from=code&amp;widget=chart&amp;resize=1\" title=\"Load this chart in a pop up\" target=\"_blank\" style=\"display:block;overflow:hidden;width:25px;height:20px;background:url(http://cdn.last.fm/widgets/images/en/footer/black.png) no-repeat -159px -20px;text-decoration:none;border:0;\" onclick=\"window.open(this.href + '&amp;resize=0','lfm_popup','height=279,width=234,resizable=yes,scrollbars=yes'); return false;\"></a></td></tr></table></td></tr></table></div><div class=\"clear\"></div>"
            end
            div.content! do
              menu[:top][:visitor] = []
              menu[:top][:admin] << a('New', :href => self / "/new#{"/#@tag" if @tag != 'Index'}") if logged_in?
              menu[:top][:admin] << a('Assets', :href => "/assets") if logged_in?
              menu[:top][:admin] << 'Logout' if logged_in?
              div.bar! { menu :top } if logged_in?
              
              self << yield
            end
              
            div.footer! { "All posts created by #{a "Brenton Fletcher", :href => "http://i.bloople.net"}. <a href='mailto:&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;'>Email me</a>! Made on a #{a "Mac", :href => "http://apple.com"}. Powered by #{a "Ruby", :href => "http://ruby-lang.org"} on #{a "blokk #{VERSION}", :href => 'http://murfy.de/read/blokk'} (modified) on #{a "Camping", :href => "http://code.whytheluckystiff.net/camping/"}." }
          end
        end
      end
    end
    
    def index
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
      links = []
      links << a('Older posts', :href => "/archive/#{@tag}/#{@page + 1}") if @has_older_posts
      links << a('Newer posts', :href => (@has_newer_posts ? "/archive/#{@tag}/#{@page - 1}" : "/"))
      p.pagination { links.join(' | ') }

      @posts.each { |post| _post post }

      p.pagination { links.join(' | ') }
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
        div.comment do
          p.body c.body
          timestamp = c.created_at.strftime('%H:%M on %A, %Y-%m-%d')
          p.username "#{c.username} @ #{timestamp}"
          a 'Delete', :href => R(Shoot, c), :onclick => "return confirm('Sure?');" if logged_in?
        end
      end
      
      form :action => R(Read, @post), :method => :post do
        div do
          label_for :name, @comment, :username, :accesskey => 'C'
          input.name! :name => :name, :value => @comment.username, :size => 41, :type => :text
        end
        div do
          label_for :comment, @comment, :body
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
          text "#{post.created_at.strftime('%H:%M %a %Y-%m-%d')} "
          text '(%s)' % post.tags.scan(/[-\w]+/).map { |t| a t, :href => R(Index, t) }.join(' ')
        end
        cs = post.comments.size
        menu[id = post.nickname || post.id][:visitor] << "#{cs} comment#{'s' unless cs == 1}"
        menu[id][:visitor] << a('Read', :href => R(Read, id)) unless full
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
    
  end
  
end