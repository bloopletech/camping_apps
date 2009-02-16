require 'lib/has_image'

module Ajas::Models
  class AnimeTitle < Base
    has_image false, 'image', [250, nil], [1000, nil]
    has_image false, 'banner', [250, nil], [950, nil]
    has_many :anime_title_comments
    
    def self.random
      find(:first, :order => 'RAND()')
    end

    def self.random_with_image
      find(:first, :conditions => 'has_image = true', :order => 'RAND()')
    end
  end
  
  class AnimeTitleComment < Base
    validates_presence_of :username
    validates_length_of :body, :within => 1..3000
    validates_inclusion_of :bot, :in => %w(K)
    validates_associated :page
    belongs_to :page
    attr_accessor :bot
  end
  
  class CreateAnimeModels < V 1.5
    def self.up
      create_table :ajas_anime_titles do |t|
        t.string :title
        t.text :description
        t.boolean :has_image
        t.datetime :showing_start
        t.datetime :showing_end
        t.float :rating
      end
    end
  end

  class AddBanner < V 2.0
    def self.up
      add_column :ajas_anime_titles, :has_baner, :boolean
    end
  end

  class AddEpisodeCount < V 2.5
    def self.up
      add_column :ajas_anime_titles, :episodes, :integer
    end
  end

  class RenameBannerAndAddComments < V 5.0
    def self.up
      rename_column :ajas_anime_titles, :has_baner, :has_banner
      
      create_table :ajas_anime_title_comments do |table|
        table.integer :anime_title_id
        table.string :username
        table.text :body
        table.datetime :created_at
      end
    end
  end
end

module Ajas::Controllers
  class AnimeAdminIndex < R '/admin/anime'
    def get
      return unless admin_logged_in?
      @anime_titles = AnimeTitle.find(:all, :order => 'title ASC')
      render :admin_anime_index
    end
  end

  class AnimeAdminCreate < R '/admin/anime/create'
    def get
      return unless admin_logged_in?
      @anime_title = AnimeTitle.new(:title => '', :description => '', :has_image => false, :has_banner => false, :showing_start => Date.today,
       :showing_end => Date.today)
      render :admin_anime_create
    end
    def post
      return unless admin_logged_in?
      @anime_title = AnimeTitle.new(:title => input.title, :description => input.description, :has_image => input.has_image,
        :image => (!input.image.nil? ? input.image[:tempfile] : nil), :has_banner => input.has_banner,
         :banner => (!input.banner.nil? ? input.banner[:tempfile] : nil), :showing_start => input.showing_start, :showing_end => input.showing_end)
      if @anime_title.save
        add_success("Added title")
        redirect '/admin/anime'
      else
        @anime_title.errors.full_messages.each { |msg| add_error(msg) }
        render :admin_anime_create
      end
    end
  end

  class AnimeAdminEdit < R '/admin/anime/edit/(\d+)'
    def get(id)
      return unless admin_logged_in?
      @anime_title = AnimeTitle.find(id.to_i)
      render :admin_anime_edit
    end
    def post(id)
      return unless admin_logged_in?
      @anime_title = AnimeTitle.find(id.to_i)
      if @anime_title.update_attributes(:title => input.title, :description => input.description, :has_image => input.has_image,
        :image => (!input.image.nil? ? input.image[:tempfile] : nil), :has_banner => input.has_banner,
         :banner => (!input.banner.nil? ? input.banner[:tempfile] : nil), :showing_start => input.showing_start, :showing_end => input.showing_end)
        add_success("Updated title")
        redirect '/admin/anime'
      else
        @anime_title.errors.full_messages.each { |msg| add_error(msg) }
        render :admin_anime_edit
      end
    end
  end

  class AnimeShowTitle < R '/anime/(\d+)'
    def get(id)
      @anime_title = AnimeTitle.find(id.to_i)
      @anime_title_comment = AnimeTitleComment.new
      render :anime_title
    end
    def post(id)
      @anime_title = AnimeTitle.find(id.to_i)
      @anime_title_comment = @anime_title.anime_title_comments.new(:username => input.username, :body => input.body, :bot => input.bot)
      if @anime_title_comment.save
        add_success("Comment posted")
        redirect "/anime/#{@anime_title.id}"
      else
        @anime_title.errors.full_messages.each { |msg| add_error(msg) }
        @anime_title_comment.errors.full_messages.each { |msg| add_error(msg) }
        render :anime_title
      end
    end
  end

  class AnimeTitleDeleteComment < R '/anime/delete_comment/(\d+)'
    def get(id)
      @anime_title_comment = AnimeTitleComment.find(id.to_i)
      anime_title_id = @anime_title_comment.anime_title_id
      @anime_title_comment.destroy
      add_success('Comment deleted')
      redirect "/anime/#{anime_title_id}"
    end
  end
end

require 'action_view/helpers/date_helper'

module Ajas::Helpers
  include ActionView::Helpers::DateHelper
  def image_column(record, name)
    has_file = record.send("has_#{name}?")
    out = "<div class='upload'>#{has_file ? img(:src => record.send("#{name}_small_url")) : ""}<div>"
    out << "#{input :type => :radio, :name => "has_#{name}", :value => '0', :onclick => "document.getElementById('#{name}').disabled = true;", :class => 'radio'} No file<br />"
    out << "#{input :type => :radio, :name => "has_#{name}", :value => '1', :onclick => "document.getElementById('#{name}').disabled = true;", :class => 'radio', :checked => 'checked'} Keep same file<br />" if has_file
    attrs = { :type => :radio, :name => "has_#{name}", :value => '1', :onclick => "document.getElementById('#{name}').disabled = false;", :class => 'radio' }
    attrs[:checked] = "checked" if !has_file
    out << "#{input attrs} Upload new file"
    attrs = { :type => :file, :name => name, :id => name, :class => 'file' }
    attrs[:disabled] = "disabled" if has_file
    attrs[:checked] = "checked" if !has_file
    out << "#{input attrs}</div><div class='clear'></div></div>"
    out
  end
end

module Ajas::Views
  def admin_anime_index
    h2 { "Anime admin" }
    p { a("Add title", :href => '/admin/anime/create') }
    table do
      tr do
        th { "Title" }
        th { "Showing Start" }
        th { "Showing End" }
        th.last_r { "Actions" }
      end
      @anime_titles.each do |a|
        attrs = {}
        attrs[:class] = 'last_b' if a == @anime_titles.last
        tr(attrs) do
          td { a.title }
          td { nice_date_time(a.showing_start) }
          td { nice_date_time(a.showing_end) }
          td.last_r { a('View', :href => "/anime/#{a.id}") + ' ' + a('Edit', :href => "/admin/anime/edit/#{a.id}") + ' ' + a('Delete', :href => "/admin/anime/delete/#{a.id}", :onclick => "return confirm('Are you sure?');") }
        end
      end
    end
  end



  def admin_anime_create
    h2 { "Anime admin: create title" }
    _admin_anime_form
  end

  def admin_anime_edit
    h2 { "Anime admin: edit title" }
    _admin_anime_form
  end

  def _admin_anime_form
    @content_for ||= {}
    @content_for[:head] = capture do
      script :type => 'text/javascript', :src => '/tiny_mce/tiny_mce.js'
      script :type => 'text/javascript', :src => '/tiny_mce_opts.js'
      script :type => 'text/javascript' do
        text "tinyMCE.init(tiny_mce_opts);"
      end
    end
    form :action => (@anime_title.new_record? ? '/admin/anime/create' : "/admin/anime/edit/#{@anime_title.id}"), :method => :post, :enctype => 'multipart/form-data' do
      div do
        label_for :title
        input :name => :title, :type => :text, :value => @anime_title.title
      end
      div do
        label_for :description
        textarea(:name => :description) do
          h @anime_title.description
        end
      end
      div do
        label_for :showing_start
        input :type => :text, :name => :showing_start, :value => @anime_title.showing_start
        #date_select 'anime_title', :showing_start
      end
      div do
        label_for :showing_end
        input :type => :text, :name => :showing_end, :value => @anime_title.showing_end
        #date_select 'anime_title', :showing_start
      end
      div do
        label_for :image
        text image_column(@anime_title, 'image')
      end
      div do
        label_for :banner
        text image_column(@anime_title, 'banner')
      end
      div do
        input :type => :submit, :class => 'submit', :value => 'Save title'
      end
    end
  end

  def anime_title
    h2 { h @anime_title.title }
    if @anime_title.has_image?
      div.anime_image! do
        img :src => @anime_title.image_small_url
      end
    end
    text @anime_title.description
    p { "Showing from #{nice_date @anime_title.showing_start} to #{nice_date @anime_title.showing_end}." }
    div.clear { "" }
    h3 { "Comments" }
    unless @anime_title.anime_title_comments.empty?
      @anime_title.anime_title_comments.each do |c|
        div.comment do
          p.body c.body
          p.username "#{c.username} @ #{nice_date_time(c.created_at)}"
          a 'Delete', :href => "/anime/delete_comment/#{c.id}", :onclick => "return confirm('Are you sure?');" if admin_logged_in?
        end
      end
    else
      p { "There aren't any comments yet!" }
    end
    h3 { "Post a comment" }
    form :action => "/anime/#{@anime_title.id}", :method => :post do
      div do
        label_for :name, @anime_title_comment, :username, :accesskey => 'C'
        input.name! :name => :username, :value => @anime_title_comment.username, :size => 41, :type => :text
      end
      div do
        label_for :comment, @anime_title_comment, :body
        textarea.comment! @anime_title_comment.body, :name => :body, :cols => 60, :rows => 10
        input.bot! :type => :hidden, :name => :bot, :value => 'spambot'
      end
      div do
        input :type => :submit, :class => :submit, :value => 'Add', :onclick => "getElementById('bot').value='K'"
      end
    end
  end
    
end