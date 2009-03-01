module Ajas::Models
  class Page < Base
    has_many :page_comments
  end
  
  class PageComment < Base
    validates_presence_of :username
    validates_length_of :body, :within => 1..3000
    validates_inclusion_of :bot, :in => %w(K)
    validates_associated :page
    belongs_to :page
    attr_accessor :bot
  end

  class CreatePage < V 4.0
    def self.up
      create_table :ajas_pages do |table|
        table.string :title, :tags, :nickname
        table.text :body
        table.timestamps
      end
      
      create_table :ajas_page_comments do |table|
        table.integer :page_id
        table.string :username
        table.text :body
        table.datetime :created_at
      end
    end
  end
end

module Ajas::Controllers
  class PageView < R '/page/(\d+)'
    def get(id)
      @page = Page.find(id.to_i)
      @page_comment = PageComment.new
      render :page
    end
    def post(id)
      @page = Page.find(id.to_i)
      @page_comment = @page.page_comments.new(:username => input.username, :body => input.body, :bot => input.bot)
      if @page_comment.save
        add_success("Comment posted")
        redirect "/page/#{@page.id}"
      else
        @page.errors.full_messages.each { |msg| add_error(msg) }
        @page_comment.errors.full_messages.each { |msg| add_error(msg) }
        render :page
      end
    end
  end

  class PageDeleteComment < R '/page/delete_comment/(\d+)'
    def get(id)
      @page_comment = PageComment.find(id.to_i)
      page_id = @page_comment.page_id
      @page_comment.destroy
      add_success('Comment deleted')
      redirect "/page/#{page_id}"
    end
  end
  

  class PageAdminIndex < R '/admin/pages'
    def get
      return unless admin_logged_in?
      @pages = Page.find(:all, :order => 'title')
      render :page_admin_index
    end
  end

  class PageAdminCreate < R '/admin/pages/create'
    def get
      return unless admin_logged_in?
      @page = Page.new(:body => '', :title => '')
      render :admin_page_create
    end
    def post
      return unless admin_logged_in?
      @page = Page.new(:title => input.title, :body => input.body)
      if @page.save
        add_success("Page created")
        redirect "/admin/pages"
      else
        @page.errors.full_messages.each { |msg| add_error(msg) }
        render :admin_page_create
      end
    end
  end

  class PageAdminEdit < R '/admin/pages/edit/(\d+)'
    def get(id)
      return unless admin_logged_in?
      @page = Page.find(id.to_i)
      render :admin_page_edit
    end
    def post(id)
      return unless admin_logged_in?
      @page = Page.find(id.to_i)
      if @page.update_attributes(:title => input.title, :body => input.body)
        add_success("Page updated")
        redirect "/admin/pages"
      else
        @page.errors.full_messages.each { |msg| add_error(msg) }
        render :admin_page_edit
      end
    end
  end

  class AdminPageDelete < R '/admin/pages/delete/(\d+)'
    def get(id)
      return unless admin_logged_in?
      Page.find(id.to_i).destroy
      add_success "Page deleted"
      redirect '/admin/pages'
    end
  end
end

module Ajas::Helpers
  
end

module Ajas::Views
  def page_admin_index
    h2 { "Pages admin" }
    p { a("Add page", :href => '/admin/pages/create') }
    table do
      tr do
        th { "Page title" }
        th { "Updated" }
        th.last_r { "Actions" }
      end
      @pages.each do |p|
        attrs = {}
        attrs[:class] = 'last_b' if p == @pages.last
        tr(attrs) do
          td { p.title }
          td { nice_date_time(p.updated_at) }
          td.last_r { a('Comments', :href => "/page/#{p.id}") + ' ' + a('Edit', :href => "/admin/pages/edit/#{p.id}") + ' ' + a('Delete', :href => "/admin/pages/delete/#{p.id}", :onclick => "return confirm('Are you sure?');") }
        end
      end
    end
  end

  def admin_page_create
    h2 { "Pages admin: create page" }
    _admin_page_form
  end

  def admin_page_edit
    h2 { "Pages admin: edit page" }
    _admin_page_form
  end

  def _admin_page_form
    @content_for ||= {}
    @content_for[:head] = capture do
      script :type => 'text/javascript', :src => '/tiny_mce/tiny_mce.js'
      script :type => 'text/javascript', :src => '/tiny_mce_opts.js'
      script :type => 'text/javascript' do
        text "tinyMCE.init(tiny_mce_opts);"
      end
    end
    form :action => (@page.new_record? ? '/admin/pages/create' : "/admin/pages/edit/#{@page.id}"), :method => :post do
      div do
        label_for :title, @page
        input :name => :title, :type => :text, :value => @page.title
      end
      div do
        label_for :body, @page
        textarea :name => :body do
          h(@page.body)
        end
      end
      div do
        input.submit :type => :submit, :name => :login, :value => 'Save page'
      end
    end
  end

  def page
    div.page do
      h2 { h @page.title }
      text @page.body
      p { "Last updated: #{nice_date_time @page.updated_at}" }
=begin
      h3 { "Comments" }
      unless @page.page_comments.empty?
        @page.page_comments.each do |c|
          div.comment do
            p.body c.body
            p.username "#{c.username} @ #{nice_date_time(c.created_at)}"
            a 'Delete', :href => "/page/delete_comment/#{c.id}", :onclick => "return confirm('Are you sure?');" if admin_logged_in?
          end
        end
      else
        p { "There aren't any comments yet!" }
      end
      h3 { "Post a comment" }
      form :action => "/page/#{@page.id}", :method => :post do
        div do
          label_for :name, @page_comment, :username, :accesskey => 'C'
          input.name! :name => :username, :value => @page_comment.username, :size => 41, :type => :text
        end
        div do
          label_for :comment, @page_comment, :body
          textarea.comment! @page_comment.body, :name => :body, :cols => 60, :rows => 10
          input.bot! :type => :hidden, :name => :bot, :value => 'spambot'
        end
        div do
          input :type => :submit, :class => :submit, :value => 'Add', :onclick => "getElementById('bot').value='K'"
        end
      end
=end
    end
  end
end