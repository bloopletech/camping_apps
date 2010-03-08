module Blog::Controllers
  class Index < R '/', '/index', '/tag/()([-\w]*)', '/all()()', '/(rss)', '/(rss)/([-\w]+)'
#    @cacheable = true

    TAG_PATTERN = ['% ? %', '? %', '% ?', '?']
    #TODO: Following code is ridiculous
    def get format = 'html', tag = 'Index'
      posts = logged_in? ? Post : Post.published

      @tag = tag
      conditions = tag ? { :conditions => TAG_PATTERN.map { |t| "tags LIKE " + ActiveRecord::Base.connection.quote(t.gsub('?', tag)) }.join(" OR ") } : {}
      @total_pages = (posts.count(:all, conditions) / 5.0).ceil
      @has_older_pages = @total_pages > 1
      standard_conds = { :order => 'published_at DESC' }
      standard_conds[:limit] = 5 if format == 'html' or format == ''
      @posts = posts.find :all, conditions.merge(standard_conds)
      render format == 'rss' ? :rss_feed : :index
    end
  end

  class Search < R '/search'
    def post
#        @page = page.to_i
#        count = Post.published.count :all, :conditions => "tags LIKE '%#{@tag}%'"
#        start = (@page * 5)
#        @has_older_posts = (start + 5) < count
#        @has_newer_posts = @page > 1
#        @total_pages = (count / 5.0).ceil
      c = ActiveRecord::Base.connection
      @search_query = input.query
      @posts = Post.published.find :all, :conditions => "title LIKE #{c.quote "%#{@search_query}%"} OR body LIKE #{c.quote "%#{@search_query}%"}", :order => 'created_at DESC'#, :limit => 5, :offset => start
      render :search
    end
  end

  class Archive < R '/archive/([-\w]*)/(\d+)'
    def get(tag, page)
      @tag = tag
      @page = page.to_i
      count = Post.published.count :all, :conditions => "tags LIKE '%#{@tag}%'"
      start = (@page * 5)
      @has_older_posts = (start + 5) < count
      @has_newer_posts = @page > 1
      @total_pages = (count / 5.0).ceil
      @posts = Post.published.find :all, :conditions => "tags LIKE '%#{@tag}%'", :order => 'created_at DESC', :limit => 5, :offset => start
      render :archive
    end
  end
  
  class New < R '/new', '/new/([-\w]*)'
    def get tag = nil
      return unless logged_in?
      @post = Post.new(:tags => "Index #{tag}".strip, :published_at => Time.now)
      render :new
    end
    def post
      @post = Post.new :title => input.title, :body => input.body, :tags => input.tags, :nickname => input.nickname,
       :published_at => input.published_at
      if @post.save
        redirect Read, @post.nickname
      else
        @post.errors.full_messages.each { |msg| add_error(msg) }
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
      puts "input: #{input.inspect}"
      @post = Post.find input['id']
      if @post.update_attributes(:title => input.title, :body => input.body, :tags => input.tags, :nickname => input.nickname, :published_at => input.published_at)
        redirect Read, @post.nickname
      else
        @post.errors.full_messages.each { |msg| add_error(msg) }
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
      (@post = Post.find(input['id'])).destroy if logged_in?
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
      return unless logged_in?
      render :assets
    end
    def post
      return unless logged_in?

      fn = "#{Time.now.to_i}_#{rand(999999)}"

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
        @headers['X-Accel-Redirect'] = "#{PATH}/public/assets/#{path}"
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
      @post = (logged_in? ? Post : Post.published).find :first, :conditions => ['id = ? OR nickname = ?', id, id]
      @comment = Comment.new :body => input.comment, :username => input.name
      render :view if @post
    end
    def post id
      @post = (logged_in? ? Post : Post.published).find :first, :conditions => ['id = ? OR nickname = ?', id, id]
      @comment = @post.comments.new :bot => input.bot, :username => (name = input.name), :body => (comment = input.comment)
      if @comment.save
        redirect self / "/read/#{id}"
      else
        @comment.errors.full_messages.each { |msg| add_error(msg) }
        render :view
      end
    end
  end
end