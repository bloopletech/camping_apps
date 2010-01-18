require "date"

module Watchlist::Views
  def layout
    content = yield
    @content_for ||= {}
    if @render_layout.nil?
      @render_layout = true
    end

    if @render_layout
      xhtml_transitional do
        head do
          title "Watchlist"
          link :rel => 'stylesheet', :type => 'text/css', :href => '/style.css', :media => 'screen'
          script :type => 'text/javascript', :src => '/prototype.js'
          script :type => 'text/javascript', :src => '/scriptaculous.js?load=effects,controls'
          script :type => 'text/javascript', :src => '/title_autocomplete.js'
          self << @content_for[:head]
        end
        body do
          div.header! do
            links = [a('Home', :href => '/'), a('About', :href => '/about')] + if logged_in?
              ["Logged in as #{a current_user.name, :href => R(ShowUser, current_user.id)}", a('Logout', :href => '/logout')]
            else
              [a('Login', :href => '/login'), a('Signup', :href => '/signup')]
            end
            div.nav! { links.join(" | ") }
            h1 { a("Watchlist", :href => '/') }
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
          p.footer! { "Created by #{a "Brenton Fletcher", :href => "http://blog.bloople.net"}. <a href='mailto:&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;'>Email me</a>! Made on a #{a "Mac", :href => "http://apple.com"}. Powered by #{a "Ruby", :href => "http://ruby-lang.org"} on #{a "Camping", :href => "http://code.whytheluckystiff.net/camping/"}." }
        end
      end
    else
      self << content
    end
  end

  def index_logged_out
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

  def signup
    form :action => R(Signup), :method => :post do
      div do
        label_for :name
        input :name => :name, :type => :text
      end
      div do
        label_for :password
        input :name => :password, :type => :password
      end
      div do
        label_for :email
        input :name => :email, :type => :text
      end
      div do
        input.submit :type => :submit, :name => :login, :value => 'Signup'
      end
    end
  end

  def show_user
    cur = (logged_in? && (@user.id == current_user.id))
    h2 { cur ? "Your page" : "#{@user.name}'s page" }
    p { "#{a('Find other users with similar interests', :href => "/users/find_similar")}" } if cur
    p { "#{a("Send #{@user.name} a message", :href => "/users/#{@user.id}/send_message")} #{a("Check your compatibility with #{@user.name}", :href => "/users/#{@user.id}/comapre_to_me")}" } unless cur
    if cur
      h3 { "Received messages" }
      mr = @user.messages_recieved.find(:all, :order => 'created_at DESC', :limit => 5)
      unless mr.empty?
        _messages(mr, true)
        p { a('More recieved messages...', :href => "/users/messages_received") }
      else
        p { "No messages" }
      end
      h3 { "Sent messages" }
      ms = @user.messages_sent.find(:all, :order => 'created_at DESC', :limit => 5)
      unless ms.empty?
        _messages(ms, true)
        p { a('More sent messages...', :href => "/users/messages_sent") }
      else
        p { "No messages" }
      end
      
    end

    h3 { cur ? "Your items" : "#{@user.name}'s items" }
    _items(@items, cur)
    p { a("More...", :href => "/users/#{@user.id}/items") }
  end

  def users_find_similar
    h2 { "Users similar to me" }
    _users(@users)
  end

  def send_user_message
    h2 { "Send a message to #{@message.recipient.name}" }
    form :action => "/users/#{@message.recipient.id}/send_message", :method => :post do
      div do
        label_for :message
        textarea :name => :message
      end
      div do
        input.submit :type => :submit, :name => :login, :value => 'Send'
      end
    end
  end

  def user_received_messages
    h2 { "Received messages" }
    _messages(@received_messages, true)
  end

  def user_sent_messages
    h2 { "Sent messages" }
    _messages(@sent_messages, true)
  end

  def user_items
    h2 { @title || "Your items" }
    _items(@items, (logged_in? && (@user.id == current_user.id)))
  end

  #item / title stuff
  def show_title
    h2 { h @title.titles }
    text gs_title(@title)
    sources = []
    sources << a('Anime News Network Encyclopdia', :href => "http://www.animenewsnetwork.com/encyclopedia/anime.php?id=#{@title.ann_id}") unless @title.ann_id.nil?
    sources << a('AniDB', :href => "http://anidb.net/perl-bin/animedb.pl?show=anime&aid=#{@title.anidb_id}") unless @title.anidb_id.nil?
    
    unless sources.empty?
      p { "View #{h @title.title} in #{sources.join(", ")}." }
    end
  end

  def _item_form
    @content_for = {}
    @content_for[:head] = capture do

    end

    input :name => :title_id, :type => :hidden, :value => (@item.title.nil? ? '' : @item.title.id), :id => 'title_id'
    div do
      label_for :title, @item
      input :name => :title, :type => :text, :value => (@item.title.nil? || @item.title.nil? ? '' : @item.title.title), :autocomplete => 'off', :id => 'title', :style => 'width: 40em;'
      div.title_autocomplete!(:class => 'autocomplete') { "" }
    end
    div do
      label_for :medium
      select(:name => :medium_id) do
          Watchlist::Models::Medium.find(:all).each do |t|
          option(:value => t.id, :selected => (!@item.title.nil? && (@item.title.medium_id == t.id))) { t.name }
        end
      end
    end
=begin
    div do
      label_for :genres
      input :name => :genre_list, :type => :text, :value => @item.genre_list
      p { "Type in genres from the list below, separating them with commas:" }
      ul do
        Watchlist::Models::Item.genre_counts.each { |g| li { g.name } }
      end
    end
=end
    div do
      label_for :consumed
      select(:name => :consumed, :id => 'consumed') do
        ['none', 'some', 'most', 'all'].each do |t|
          option(:value => t, :selected => (@item.title.type == t)) { t }
        end
      end
    end
    div do
      input.submit :type => :submit, :name => :add, :value => 'Add', :id => 'submit'
    end
  end

  def autocomplete_title
    @render_layout = false
    ul do
      @titles.each do |title|
        li(:id => title.id) { title.titles }
      end
    end
  end

  def create_item
    h2 { "Add an item" }
    form :action => '/items/create', :method => :post do
      _item_form
    end
  end

  def create_item_ajax_result
    @render_layout = false
    i = @item
    t = @item.title
    text({ :title => t.title, :title_id => t.id, :consumed => i.consumed, :when => nice_date(i.updated_at), :links => (a("Edit", :href => "/items/#{i.id}/update") + ' ' + a("Delete", :href => "/items/#{i.id}/destroy", :onclick => 'return confirm("Are you sure?");')) }.to_json)
  end
    

  def update_item
    h2 { "Update #{h @item.title.title}" }
    form :action => "/items/#{@item.id}/update", :method => :post do
      _item_form
    end
  end

  def _items(items, render_form = false)
    @content_for = {}
    @content_for[:head] = capture do
    end

    form.create_form! do
      table do
        thead do
          tr do
            th { "Title" }
            th { "Consumed?" }
            th { "Last Updated" }
            th.last_r { }
          end
        end
        tbody.table_body! do
          items.each do |i|
            #puts "items.last: #{items.last.inspect}"
            attrs = {}
            attrs[:class] = 'last_b' if i == items.last && !(logged_in? and items.last.user == current_user)
            tr(attrs) do
              td { a(i.title.title, :href => "/#{i.title.id}") }
              td { h i.consumed }
              td { nice_date i.updated_at }
              td.last_r do
                if logged_in? and items.last.user == current_user
                  a("Edit", :href => "/items/#{i.id}/update") + ' ' + a("Delete", :href => "/items/#{i.id}/destroy", :onclick => 'return confirm("Are you sure?");')
                else
                  a('Add to my list', :href => "/items/create?title_id=#{i.title.id}")
                end
              end
            end
          end
          if logged_in? and render_form
            tr.last_b do
              td do
                input :type => :hidden, :id => 'title_id', :name => 'title_id'
                input :type => :text, :id => 'title', :name => 'title'
                div.title_autocomplete!(:class => 'autocomplete') { "" }
                text " "
                select(:name => :medium_id, :id => 'medium_id') do
                    Watchlist::Models::Medium.find(:all).each do |t|
                    option(:value => t.id) { t.name.humanize }
                  end
                end
              end
              td do
                select(:name => :consumed, :id => 'consumed') do
                  %w(None Some Most All).each do |t|
                    option(:value => t) { t }
                  end
                  option(:value => 'list') { 'List...' }
                end
                text " "
                input :type => 'text', :id => 'consumed_advanced', :name => 'consumed_advanced', :style => 'display: none;'
              end
              td { nice_date Date.today }
              td.last_r { input :type => 'submit', :class => 'submit', :id => 'submit', :value => 'Add' }
            end
          end
        end
      end
    end
    #will_paginate items
  end

  def _messages(messages, sending = false)
    form.message_create_form! do
      table do
        tbody do
          tr do
            th { "Sender" }
            th { "Message" }
            th.last_r { "Date received" }
          end
          messages.each do |m|
            attrs = {}
            attrs[:class] = 'last_b' if m == messages.last && !sending
            tr(attrs) do
              td { a(m.sender.name, :href => "/users/#{m.sender.id}") }
              td { m.message }
              td.last_r { nice_date m.sender.created_at }
            end
          end
        end
      end
    end
  end
  
  def _users(users)
    table do
      tr do
        th.last_r { "Username" }
      end
      users.each do |user|
        attrs = {}
        attrs[:class] = 'last_b' if user == users.last
        tr(attrs) do
          td.last_r { a(user.name, :href => "/users/#{user.id}") }
        end
      end
    end
  end
end