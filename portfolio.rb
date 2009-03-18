# encoding: utf-8

require 'camping/session'
require 'htmlentities/string'
require 'lib/acts-as-taggable-on/models'
require 'lib/acts-as-taggable-on/acts_as_taggable_on'
require 'lib/acts-as-taggable-on/acts_as_tagger'
require 'lib/common'
require 'lib/has_image'

Camping.goes :Portfolio

module Portfolio
  include Camping::Session
  PATH = File.expand_path(File.dirname(__FILE__)) + '/portfolio'
end

module Portfolio::Models
  include ActsAsTaggableModels
  Base.send :include, ActiveRecord::Acts::TaggableOn
  Base.send :include, ActiveRecord::Acts::Tagger

  class Work < Base
    acts_as_taggable_on :tags
    has_image(true, 'image', [120, 120], [120, 120])
  end

  class CreatePortfolio < V 0.1
    def self.up
      create_table :portfolio_tags do |t|
        t.column :name, :string
      end

      create_table :portfolio_taggings do |t|
        t.column :tag_id, :integer
        t.column :taggable_id, :integer
        t.column :tagger_id, :integer
        t.column :tagger_type, :string

        # You should make sure that the column created is
        # long enough to store the required class names.
        t.column :taggable_type, :string
        t.column :context, :string

        t.column :created_at, :datetime
      end

      add_index :portfolio_taggings, :tag_id, :name => "index_ptflo_taggings_on_tag_id"
      add_index :portfolio_taggings, [:taggable_id, :taggable_type, :context], :name => "index_ptflo_taggings_on_tid_ttype_ctext"

      create_table :portfolio_works do |t|
        t.column :title, :string
        t.column :url, :string
        t.column :description, :text
        t.column :has_image, :boolean
        t.column :created, :datetime
        t.column :active, :boolean, :default => true
        t.column :flash_movie, :string
      end
    end
  end
end

module Portfolio::Controllers
  class AdminLogin < R '/admin/login'
    def get
      render :admin_login
    end
    
    def post
      if input.user == "bloopletech" and input.pass == PORTFOLIO_PASSWORD
        @state.admin = true
        redirect '/admin/'
      else
        redirect '/admin/login'
      end
    end
  end

  class AdminList < R '/admin/'
    def get
      return unless admin?
      if input.q
        @heading = "Works with tag '#{input.q}'"
        @works = Work.find_tagged_with(input.q, :order => 'LOWER(title)')
      else
        @heading = 'All Works'
        @works = Work.find(:all, :order => 'LOWER(title)')
      end
      puts "works: #{@works.inspect}"
      @tags = Work.tag_counts
      puts "tags: #{@tags.inspect}"

      render :admin_list
    end
  end

  class AdminCreate < R '/admin/create'
    def get
      return unless admin?
      @work = Work.new(:url => "http://", :active => true)
      render :admin_create
    end
    
    def post
      return unless admin?
      @work = Work.new(:title => input.title, :url => input.url, :description => input.description, :has_image => input.has_image,
       :image => (!input.image.nil? ? input.image[:tempfile] : nil), :flash_movie => input.flash_movie, :tag_list => input.tag_list, :active => input.active)
      @work.created = DateTime.now
      if @work.save
        redirect '/admin/'
      else
        render :admin_create
      end
    end
  end

  class AdminEdit < R '/admin/(\d+)/edit'
    def get(id)
      return unless admin?
      @work = Work.find(id.to_i)
      render :admin_edit
    end

    def post(id)
      return unless admin?
      @work = Work.find(id.to_i)
      @work.update_attributes(:title => input.title, :url => input.url, :description => input.description, :has_image => input.has_image,
       :image => (!input.image.nil? ? input.image[:tempfile] : nil), :flash_movie => input.flash_movie, :tag_list => input.tag_list, :active => input.active)
      if @work.save
        redirect '/admin/'
      else
        render :admin_create
      end
    end
  end

  class Index < R '/'
    def get
      @latest_work = Work.find(:all, :conditions => "active=TRUE", :order => 'created DESC', :limit => 1)
      fw = Work.find_tagged_with('home_page', :conditions => "active=TRUE")
      @featured_works_1 = fw[0..(fw.size/2 - 1)]
      @featured_works_2 = fw[(fw.size/2)..fw.size]
      @tags = Work.tag_counts
      render :index
    end
  end

  class Tagged < R '/tagged/(.+)'
    def get(id)
      @search_terms = id
      @works = Work.find_tagged_with(@search_terms, :conditions => "active=TRUE").sort { rand <=> 0.5 }
      @tags = Work.tag_counts
      render :tagged
    end
  end
  
  class Show < R '/(\d+)'
    def get
      @search_terms = "id #{params[:id]}"
      @works = [Work.find(params[:id].to_i, :conditions => "active=TRUE")]
      @tags = Work.tag_counts
      render :tagged
    end
  end

  include AssetsClass
end

module Portfolio::Helpers
  def label_for name, record = nil, attr = name, options = {}
    errors = record && !record.valid? && record.errors.on(attr)
    label name.to_s.humanize, { :for => name }, options.merge(errors ? { :class => :error } : {})
  end

  def admin?
    @state.admin
  end

  def nice_date(date)
    return date.strftime("%d/%m/%Y")
  end

  def nice_date_time(date)
    return date.strftime("%d/%m/%Y %I:%M%p")
  end

  def h(text)
    CGI::escapeHTML(text)
  end

  def tag_cloud(tags, classes)
    return if tags.empty?
    max_count = tags.sort_by(&:count).last.count.to_f
    
    tags.each do |tag|
      index = ((tag.count / max_count) * (classes.size - 1)).round
      yield tag, classes[index]
    end
  end

  begin
    require_library_or_gem "superredcloth" unless Object.const_defined?(:SuperRedCloth)
    def textilize(text)
      if text.blank?
        ""
      else
        textilized = SuperRedCloth.new(text)
        textilized.to_html
      end
    end # def textilize
  rescue LoadError
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
end

module Portfolio::Views
  def layout
    xhtml_transitional do
      head do
        title "Portfolio"
        link :rel => 'stylesheet', :type => 'text/css', :href => '/style.css', :media => 'screen'
        script :type => 'text/javascript', :src => '/js.js'
        link :rel => 'shortcut icon', :href => '/favicon.ico'
      end
      body do
        div.wrap! do
          div.header! { a('', :href => '/') }
          self << yield
          div.copyright! { '&copy; 2008 Brenton Fletcher. Comments? <a href="mailto:&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;">&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;</a>. Made on a Mac with Ruby on Rails.' }
        end
      end
    end
  end

  def index
    h2 { "About Me" }
    p { "Welcome to the portfolio of Brenton Fletcher. Here you will find a selection of the works I have created as a developer over a wide range of languages and technologies- just click on the tag cloud below. I currently hold the position of Ruby on Rails developer with the award-winning <a href='http://www.katalyst.com.au'>Katalyst Web Design</a> in Adelaide, SA, Australia. My work has been mentioned in the media several times, <a href='/tagged/media'>click here</a> to see them all." }

    h2 { "Featured Works" }
    div.works_wrapper do
      @featured_works_1.each do |fw|
        _featured_work(fw, true, @featured_works_1.first == fw)
      end
    end

    div(:class => 'works_wrapper works_wrapper_last') do
      @featured_works_2.each do |fw|
        _featured_work(fw, true, @featured_works_2.first == fw)
      end
    end

    div.clear { "" }
    
    h2 { "Works by category" }
    p do
      tag_cloud @tags.sort { |a, b| a.name.downcase <=> b.name.downcase }, %w(css1 css2 css3 css4) do |tag, css_class|
        a(tag.name, :href => "/tagged/#{tag.name}", :class => css_class)
        text ' '
      end
    end

    p.works_count { "There are #{Portfolio::Models::Work.count} items in my portfolio." }
  end

  def tagged
    h2 { "Works by category" }
    p do
      tag_cloud @tags.sort { |a, b| a.name.downcase <=> b.name.downcase }, %w(css1 css2 css3 css4) do |tag, css_class|
        a(tag.name, :href => "/tagged/#{tag.name}", :class => css_class)
        text ' '
      end
    end

    h2 { "Works tagged with #{@search_terms}" }
    @works.each do |work|
      _work(work, work == @works.first)
    end
  end

  def _featured_work(work, featured, first)
    classes = "featured_work"
    classes << " featured_work_first" if first
    div(:class => classes) do
      h3 { a(h(work.title), :href => work.url) } unless work.url.nil? or work.url.blank?
      object(:type => 'application/x-shockwave-flash', :data => "/flash/#{work.flash_movie}", :width => 480, :height => 400) do
        param :name => 'movie', :data => "/flash/#{work.flash_movie}"
      end
      div.desc do
        textilize work.description
      end
      div.clear { "" }
    end
  end
    
  def _work(work, first)
    classes = "work"
    classes << " work_first" if first
    div(:class => classes) do
      div.image do
        img :src => work.image_url if work.has_image?
      end
      div.desc do
        if work.url.nil? or work.url.blank?
          h3 { h(work.title) }
        else
          h3 { a(h(work.title), :href => work.url) }
        end
        text textilize work.description
      end
      div.clear { "" }
    end
  end



  def admin_login
    form :action => '/admin/login', :method => :post do
      div do
        label_for :user
        input :name => :user, :type => :text
      end
      div do
        label_for :pass
        input :name => :pass, :type => :password
      end
      div do
        input.submit :type => :submit, :name => :login, :value => 'Login'
      end
    end
  end

  def admin_list
    h2 { @heading }
    p { a('Add work', :href => "/admin/create") }

    table do
      tr do
        th { "Name" }
        th { "Created" }
        th { }
      end
      @works.each do |work|
        tr do
          td { a(work.title, :href => "/admin/#{work.id}/edit") }
          td { nice_date work.created }
          td { a("Delete", :href => "/admin/#{work.id}/destroy", :onclick => "return confirm('Are you surety sure?');") }
        end
      end
    end

    h2 { "Works by category" }
    p do
      tag_cloud @tags.sort { |a, b| a.name.downcase <=> b.name.downcase }, %w(css1 css2 css3 css4) do |tag, css_class|
        a(h(tag.name), :href => "/admin/#{h tag.name}", :class => css_class)
      end
    end

    p { "I've created a total of #{Portfolio::Models::Work.count} works." }
    p { a('Show all works', :href => '/admin/') }
  end

  def _admin_form
    div do
      label_for :title
      input :name => :title, :type => :text, :value => @work.title
    end
    div do
      label_for :url
      input :name => :url, :type => :text, :value => @work.url
    end
    div do
      label_for :description
      textarea :name => :description do
        @work.description
      end
    end
    div do
      label_for :image
      text image_column(@work, 'image')
    end
    div do
      label_for :flash_movie
      input :name => :flash_movie, :type => :text, :value => @work.flash_movie
    end
    div do
      label_for :tags
      input :name => 'tag_list', :value => @work.tag_list
    end
    div do
      label_for :active
      input :type => :checkbox, :value => '1', :checked => @work.active?
    end
    div do
      input.submit :type => :submit, :name => :login, :value => 'Save'
    end    
  end
  
  def admin_create
    form :action => '/admin/create', :method => :post, :enctype => 'multipart/form-data' do
      _admin_form
    end
  end

  def admin_edit
    form :action => "/admin/#{@work.id}/edit", :method => :post, :enctype => 'multipart/form-data' do
      _admin_form
    end
  end
end

def Portfolio.create
  Portfolio::Models.create_schema
  ActiveRecord::Base.default_timezone = :utc
end