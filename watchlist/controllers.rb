module Watchlist::Controllers
  class Index < R '/'
    def get
      if logged_in?
        @items = current_user.items.paginate(:all, :order => 'updated_at DESC', :page => input.page, :per_page => 100)
        render :index_logged_in
      else
        render :index_logged_out
      end
    end
  end

  class CreateItem < R '/items/create'
    def get
      return unless logged_in?

      @item = current_user.items.new
      render :create_item
    end

    def post
      return unless logged_in?
      if input.title_id == ''
        medium = Medium.find(input.medium_id)
        title = Title.create(:title_main => input.title, :title_suffix => medium.name, :medium => medium)
      else
        title = Title.find(input.title_id)
      end
      if current_user.items.find_by_title_id(title.id)
        mab { text({ :error => "You've already added this title to your watchlist." }.to_json) }
      else
        @item = current_user.items.new(:title_id => title.id, :consumed => input.consumed == 'list' ? input.consumed_advanced : input.consumed)
        if @item.save
          if !input.ajax.nil?
            render :create_item_ajax_result
          else
            add_success("Item saved")
            redirect "/"
          end
        else
          @item.errors.full_messages.each { |msg| add_error(msg) }
          render :create_item
        end
      end
    end
  end

  class UpdateItem < R '/items/(\d+)/update'
    def get(id)
      return unless logged_in?
      @item = current_user.items.find(id)
      render :update_item
    end

    def post(id)
      return unless logged_in?
      if input.title_id == ''
        medium = Medium.find_by_name(input.medium)
        title = Title.create(:title => input.title, :type => medium.name, :medium => medium)
      else
        title = Title.find(input.title_id)
      end
      @item = current_user.items.find(id)
      if @item.update_attributes(:title_id => title.id, :consumed => input.consumed)
        add_success("Item updated")
        redirect "/users/#{current_user.id}"
      else
        @item.errors.full_messages.each { |msg| add_error(msg) }
        render :update_item
      end
    end
  end

  class DestroyItem < R '/items/(\d+)/destroy'
    def get(id)
      return unless logged_in?
      @item = current_user.items.find(id).destroy
      add_success("Item deleted")
      redirect "/users/#{current_user.id}"
    end
  end

  class Login < R '/login', '/logout'
    def post
      login input.username, input.password
      if logged_in?
        add_success("Logged in!")
        redirect("/users/#{current_user.id}")
      else
        add_error("Your username or password was incorrect.")
        get
      end
    end
    def get
      logout
      render :login
    end
  end
  
  Logout = Login

  class Signup
    def get
      @user = User.new
      render :signup
    end
    
    def post
      @user = User.new(:name => input.name, :password => input.password, :email => input.email)
      if @user.save
        add_success("User created.")
        redirect '/login'
      else
        @user.errors.full_messages.each { |msg| add_error(msg) }
        render :signup
      end
    end
  end

  class ShowUser < R '/users/(\d+)'
    def get(id)
      @user = User.find(id)
      @items = @user.items.find(:all, :order => 'updated_at DESC')
      render :show_user
    end
  end

  class UsersItems < R '/users/(\d+)/items'
    def get(id)
      @user = User.find(id)
      @items = @user.items.find(:all, :order => 'created_at DESC')
      render :user_items
    end
  end

  class UsersFindSimilar < R '/users/find_similar'
    def get
      return unless logged_in?
      @users = current_user.find_users_who_like_same_titles
      render :users_find_similar
    end
  end

  class ReceivedMessages < R '/users/received_messages'
    def get
      return unless logged_in?
      @received_messages = current_user.messages_received.find(:all, :order => 'created_at DESC')
      render :user_received_messages
    end
  end

  class SentMessages < R '/users/sent_messages'
    def get
      return unless logged_in?
      @sent_messages = current_user.messages_sent.find(:all, :order => 'created_at DESC')
      render :user_sent_messages
    end
  end

  class SendUserMessage < R '/users/(\d+)/send_message'
    def get(id)
      return unless logged_in?
      @message = Message.new(:recipient => User.find(id), :sender => current_user)
      render :send_user_message
    end
    
    def post(id)
      return unless logged_in?
      @message = Message.new(:recipient => User.find(id), :sender => current_user, :message => input.message)
      if @message.save
        add_success("Message sent!")
        redirect "/users/#{current_user.id}"
      else
        @message.errors.full_messages.each { |msg| add_error(msg) }
        render :send_user_message
      end
    end
  end



  class ShowTitle < R '/titles/(\d+)'
    def get(id)
      @title = Title.find(id.to_i)
      render :show_title
    end
  end


  class AutocompleteTitle < R '/autocomplete/title'
    def get
     @titles = (input.title.nil? or input.title.blank?) ? [] : Title.find_all_by_title(input.title, false)
     render :autocomplete_title
    end
  end

  include StaticAssetsClass
end