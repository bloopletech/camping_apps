require 'lib/has_image'

module Ajas::Models
  class WhatsNext < Base
  end
  
  class CreateWhatsNextModels < V 3.1
    def self.up
      create_table :ajas_whats_nexts do |t|
        t.text :description
      end
      WhatsNext.create(:description => '')
    end
  end
end

module Ajas::Controllers
  class AnimeWhatsNextIndex < R '/admin/whats_next'
    def get
      return unless admin_logged_in?
      @whats_next = WhatsNext.find(:first)
      render :admin_whats_next_index
    end
  end

  class AnimeWhatsNextEdit < R '/admin/whats_next/edit'
    def get()
      return unless admin_logged_in?
      @whats_next = WhatsNext.find(:first)
      render :admin_whats_next_edit
    end
    def post()
      return unless admin_logged_in?
      @whats_next = WhatsNext.find(:first)
      if @whats_next.update_attributes(:description => input.description)
        add_success("Updated what's next")
        redirect '/admin/whats_next'
      else
        @whats_next.errors.full_messages.each { |msg| add_error(msg) }
        render :admin_whats_next_edit
      end
    end
  end
end

module Ajas::Helpers
end

module Ajas::Views
  def admin_whats_next_index
    h2 { "What's next admin" }
    p { "Curent what's next: " }
    text @whats_next.description
    p { a('Edit what\'s next', :href => '/admin/whats_next/edit') }
  end

  def admin_whats_next_edit
    h2 { "What's next admin: edit" }
    @content_for ||= {}
    @content_for[:head] = capture do
      script :type => 'text/javascript', :src => '/tiny_mce/tiny_mce.js'
      script :type => 'text/javascript', :src => '/tiny_mce_opts.js'
      script :type => 'text/javascript' do
        text "tinyMCE.init(tiny_mce_opts);"
      end
    end
    form :action => '/admin/whats_next/edit', :method => :post, :enctype => 'multipart/form-data' do
      div do
        label_for :description
        textarea(:name => :description) do
          h @whats_next.description
        end
      end
      div do
        input :type => :submit, :class => 'submit', :value => 'Save title'
      end
    end
  end
end