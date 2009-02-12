module Ajas::Models
  class BlogPost < Base
    has_many :blog_comments
  end
  
  class BlogComment < Base
    validates_presence_of :username
    validates_length_of :body, :within => 1..3000
    validates_inclusion_of :bot, :in => %w(K)
    validates_associated :blog_post
    belongs_to :blog_post
    attr_accessor :bot
  end

  class CreateBlog < V 1.1
    def self.up
      create_table :ajas_blog_posts do |table|
        table.string :title, :tags, :nickname
        table.text :body
        table.timestamps
      end
      
      create_table :ajas_blog_comments do |table|
        table.integer :blog_post_id
        table.string :username
        table.text :body
        table.datetime :created_at
      end
    end
  end
end

module Ajas::Controllers
=begin
  class BlogIndex < R '/'
    def get
      @blog_posts = BlogPost.find(:all, :order => 'created_at DESC', :limit => 5)
      render :blog_index
    end
  end
=end
  
  class BlogIndexRss < R '/index.rss'
    def get
      @blog_posts = BlogPost.find(:all, :order => 'created_at DESC', :limit => 30)
      render :blog_archive_rss
    end
  end

  class BlogArchive < R '/blog/archive/(\d+)'
    def get(page)
      @page = page.to_i
      count = BlogPost.count(:all) - 1
      start = ((@page - 1) * 5) + 1
      @has_older_posts = (start + 5) < count
      @has_newer_posts = @page > 1
      @blog_posts = BlogPost.find(:all, :order => 'created_at DESC', :limit => 5, :offset => start)
      render :blog_archive
    end
  end

  class BlogPostView < R '/blog/(\d+)'
    def get(id)
      @blog_post = BlogPost.find(id.to_i)
      @blog_comment = BlogComment.new
      render :blog_post
    end
    def post(id)
      @blog_post = BlogPost.find(id.to_i)
      @blog_comment = @blog_post.blog_comments.new(:username => input.username, :body => input.body, :bot => input.bot)
      if @blog_comment.save
        add_success("Comment posted")
        redirect "/blog/#{@blog_post.id}"
      else
        @blog_post.errors.full_messages.each { |msg| add_error(msg) }
        @blog_comment.errors.full_messages.each { |msg| add_error(msg) }
        render :blog_post
      end
    end
  end

  class BlogPostDeleteComment < R '/blog/delete_comment/(\d+)'
    def get(id)
      @blog_comment = BlogComment.find(id.to_i)
      post_id = @blog_comment.blog_post_id
      @blog_comment.destroy
      add_success('Comment deleted')
      redirect "/blog/#{post_id}"
    end
  end
  

  class BlogAdminIndex < R '/admin/blog'
    def get
      return unless admin_logged_in?
      @blog_posts = BlogPost.find(:all, :order => 'created_at DESC')
      render :blog_admin_index
    end
  end

  class BlogAdminCreate < R '/admin/blog/create'
    def get
      return unless admin_logged_in?
      @blog_post = BlogPost.new(:body => '', :title => '')
      render :admin_blog_post_create
    end
    def post
      return unless admin_logged_in?
      @blog_post = BlogPost.new(:title => input.title, :body => input.body)
      if @blog_post.save
        add_success("Blog post created")
        redirect "/admin/blog"
      else
        @blog_post.errors.full_messages.each { |msg| add_error(msg) }
        render :admin_blog_post_create
      end
    end
  end

  class BlogAdminEdit < R '/admin/blog/edit/(\d+)'
    def get(id)
      return unless admin_logged_in?
      @blog_post = BlogPost.find(id.to_i)
      render :admin_blog_post_edit
    end
    def post(id)
      return unless admin_logged_in?
      @blog_post = BlogPost.find(id.to_i)
      if @blog_post.update_attributes(:title => input.title, :body => input.body)
        add_success("Blog post updated")
        redirect "/admin/blog"
      else
        @blog_post.errors.full_messages.each { |msg| add_error(msg) }
        render :admin_blog_post_edit
      end
    end
  end

  class AdminBlogDelete < R '/admin/blog/delete/(\d+)'
    def get(id)
      return unless admin_logged_in?
      BlogPost.find(id.to_i).destroy
      add_success "Blog post deleted"
      redirect '/admin/blog'
    end
  end
end

module Ajas::Helpers
  
end

module Ajas::Views
  def blog_admin_index
    h2 { "Blog admin" }
    p { a("Add blog post", :href => '/admin/blog/create') }
    table do
      tr do
        th { "Post title" }
        th { "Posted" }
        th.last_r { "Actions" }
      end
      @blog_posts.each do |p|
        attrs = {}
        attrs[:class] = 'last_b' if p == @blog_posts.last
        tr(attrs) do
          td { p.title }
          td { nice_date_time(p.created_at) }
          td.last_r { a('Comments', :href => "/blog/#{p.id}") + ' ' + a('Edit', :href => "/admin/blog/edit/#{p.id}") + ' ' + a('Delete', :href => "/admin/blog/delete/#{p.id}", :onclick => "return confirm('Are you sure?');") }
        end
      end
    end
  end

  def admin_blog_post_create
    h2 { "Blog admin: create blog post" }
    _admin_blog_post_form
  end

  def admin_blog_post_edit
    h2 { "Blog admin: edit blog post" }
    _admin_blog_post_form
  end

  def _admin_blog_post_form
    @content_for ||= {}
    @content_for[:head] = capture do
      script :type => 'text/javascript', :src => '/tiny_mce/tiny_mce.js'
      script :type => 'text/javascript', :src => '/tiny_mce_opts.js'
      script :type => 'text/javascript' do
        text "tinyMCE.init(tiny_mce_opts);"
      end
    end
    form :action => (@blog_post.new_record? ? '/admin/blog/create' : "/admin/blog/edit/#{@blog_post.id}"), :method => :post do
      div do
        label_for :title, @blog_post
        input :name => :title, :type => :text, :value => @blog_post.title
      end
      div do
        label_for :body, @blog_post
        textarea :name => :body do
          h(@blog_post.body)
        end
      end
      div do
        input.submit :type => :submit, :name => :login, :value => 'Save post'
      end
    end
  end

  def blog_index
    blog_list_posts
    p { a('Older posts', :href => "/blog/archive/1") } unless Ajas::Models::BlogPost.count(:all) <= 5
  end

  def blog_archive
    h2 { "Blog posts archive page #{@page}" }
    blog_list_posts
    links = []
    links << a('Older posts', :href => "/blog/archive/#{@page + 1}") if @has_older_posts
    links << a('Newer posts', :href => (@has_newer_posts ? "/blog/archive/#{@page - 1}" : "/"))
    p { links.join(' | ') }
  end

  def blog_archive_rss
    @render_layout = false
    rss = ::RSS.feed(:title => 'AJAS Blog Posts', :about => 'http://ajas.org.au', :link => 'http://ajas.org.au/',
     :description => 'AJAS Blog Posts') do |feed|
     @blog_posts.each { |post| feed.item :title => post.title, :link => "/blog/#{post.id}", :date => post.created_at, :description => post.body }
    end
    r(200, rss.to_s, 'Content-Type' => 'application/rss+xml; charset=UTF-8')
  end

  def blog_list_posts
    @blog_posts.each do |p|
      div.blog_post do
        h2 { a(p.title, :href => "/blog/#{p.id}#comments") }
        text p.body
        p { "Posted: #{nice_date_time p.created_at}" }
      end
    end
  end

  def blog_post
    div.blog_post do
      h2 { h @blog_post.title }
      text @blog_post.body
      p { "Posted: #{nice_date_time @blog_post.created_at}" }
      h3 { "Comments" }
      unless @blog_post.blog_comments.empty?
        @blog_post.blog_comments.each do |c|
          div.comment do
            p.body c.body
            p.username "#{c.username} @ #{nice_date_time(c.created_at)}"
            a 'Delete', :href => "/blog/delete_comment/#{c.id}", :onclick => "return confirm('Are you sure?');" if admin_logged_in?
          end
        end
      else
        p { "There aren't any comments yet!" }
      end
      h3 { "Post a comment" }
      form :action => "/blog/#{@blog_post.id}", :method => :post do
        div do
          label_for :name, @blog_comment, :username, :accesskey => 'C'
          input.name! :name => :username, :value => @blog_comment.username, :size => 41, :type => :text
        end
        div do
          label_for :comment, @blog_comment, :body
          textarea.comment! @blog_comment.body, :name => :body, :cols => 60, :rows => 10
          input.bot! :type => :hidden, :name => :bot, :value => 'spambot'
        end
        div do
          input :type => :submit, :class => :submit, :value => 'Add', :onclick => "getElementById('bot').value='K'"
        end
      end
    end
  end
end