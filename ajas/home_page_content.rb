require 'lib/has_image'

module Ajas::Models
  class HomePageContent < Base
  end
  
  class CreateHomePageContentModels < V 3.2
    def self.up
      create_table :ajas_home_page_contents do |t|
        t.text :description
      end
      HomePageContent.create(:description => '')
    end
  end
end

module Ajas::Controllers
  class AnimeHomePageContentIndex < R '/admin/home_page_content'
    def get
      return unless admin_logged_in?
      @home_page_content = HomePageContent.find(:first)
      render :admin_home_page_content_index
    end
  end

  class AnimeHomePageContentEdit < R '/admin/home_page_content/edit'
    def get()
      return unless admin_logged_in?
      @home_page_content = HomePageContent.find(:first)
      render :admin_home_page_content_edit
    end
    def post()
      return unless admin_logged_in?
      @home_page_content = HomePageContent.find(:first)
      if @home_page_content.update_attributes(:description => input.description)
        add_success("Updated home page content")
        redirect '/admin/home_page_content'
      else
        @home_page_content.errors.full_messages.each { |msg| add_error(msg) }
        render :admin_home_page_content_edit
      end
    end
  end
end

module Ajas::Helpers
end

module Ajas::Views
  def admin_home_page_content_index
    h2 { "Home page content admin" }
    p { "Curent home page content: " }
    text @home_page_content.description
    p { a('Edit home page content', :href => '/admin/home_page_content/edit') }
  end

  def admin_home_page_content_edit
    h2 { "Home page content admin: edit" }
    @content_for ||= {}
    @content_for[:head] = capture do
      script :type => 'text/javascript', :src => '/tiny_mce/tiny_mce.js'
      script :type => 'text/javascript', :src => '/tiny_mce_opts.js'
      script :type => 'text/javascript' do
        text "tinyMCE.init(tiny_mce_opts);"
      end
    end
    form :action => '/admin/home_page_content/edit', :method => :post, :enctype => 'multipart/form-data' do
      div do
        label_for :description
        textarea(:name => :description) do
          h @home_page_content.description
        end
      end
      div do
        input :type => :submit, :class => 'submit', :value => 'Save title'
      end
    end
  end
end