# encoding: utf-8

Camping.goes :M

module M::Models
  class Message < Base
    CONV = %w(0 1 2 3 4 5 6 7 8 9 a b c d e f g h i j k l m n o p q r s t u v w x y z A B C D E F G H I J K L M N O P Q R S T U V W X Y Z)

    def mhash
      out = ''
      num = self.id
      mult = 7 #precalced, allows for num > 99999999999999
      mult -= 1 while CONV.length ** mult > num && mult > 0

      while num >= 0 && mult >= 0
        quotient, modulus = num.divmod(CONV.length ** mult)

        if modulus > 0 or mult == 0
          out << CONV[quotient]
          num = modulus
        end
        mult -= 1
      end
      out
    end

    def self.mdehash(str)
      sum = 0
      str.split(//).each_with_index do |digit, index|
        sum += CONV.index(digit) * (CONV.length ** (str.length - 1 - index))
      end
      sum
    end
  end
  
  class CreateMessages < V 1.0
    def self.up
      create_table :m_messages do |t|
        t.column :message, :string, :limit => 255
      end
    end
    
    def self.down
      drop_table :m_messages
    end
  end
end

module M::Controllers
  class Index < R '/'
    def get
      render :index
    end
  end
  class List
    def get
      @messages = Message.find(:all, :limit => 100, :order => 'id DESC')
      render :list
    end
  end
  class Create
    def get
      render :create
    end
    
    def post
      @message = Message.create(:message => input.message[0..255])
      render :created
    end
  end
  class Show < R '/([A-z0-9]+)'
    def get(id)
      begin
        @message = Message.find(Message.mdehash(id)).message
      rescue ActiveRecord::RecordNotFound
        @message = "404, message not found"
      end
      render :show
    end
  end

  class Style < R '/style.css'
    def get
      @headers["Content-Type"] = "text/css; charset=utf-8"
      @body = %{
        * { margin: 0; padding: 0; }
        html, body { height: 100%; }
        body { font-family: "Trebuchet MS", Helvetica, Arial, sans-serif; background-color: #ffffff; color: #000000; }
        table { width: 100%; height: 100%; }
        td { vertical-align: middle; text-align: center; padding: 1em; font-size: 3.4em; line-height: 1.2em; position: relative; }
        a { color: #0000ff; text-decoration: none; }
        a:hover { text-decoration: underline; }

        #desc { font-size: 0.7em; }

        form { position: absolute; bottom: 5px; left: 5px; right: 5px; padding: 0 5px 0 5px; }

        #create_message { font-size: 100%; text-align: center; width: 100%; }
        #create_message.viewing { color: #808080; }
        #create_message.editing { color: #000000; }

        .list_message { font-size: 0.35em; padding: 0.3em 0; border-bottom: 1px solid #a0a0a0; text-align: left; }
        #list_last { border-bottom: none; }
      }
    end
  end

  class Script < R '/js.js'
    def get
      @headers["Content-Type"] = "text/javascript; charset=utf-8"
      @body = %{
        var isIE = (window.all && !window.opera);
        var instructions = "Create a message? Type here, hit <enter>"

        function niceFocus(event)
        {
           var ele = (isIE ? event.srcElement : event.target);

           if(ele.value == instructions)
           {
              ele.value = '';
              ele.className = 'editing';
           }
        }

        function niceBlur(event)
        {
           var ele = (isIE ? event.srcElement : event.target);

           if(ele.value == '')
           {
              ele.className = 'viewing';
              ele.value = instructions;
           }
        }

        function load()
        {
           var createMessage = document.getElementById('create_message');
           if(createMessage)
           {
              createMessage.className = "viewing";
              createMessage.value = instructions;
              createMessage.onfocus = niceFocus;
              createMessage.onblur = niceBlur;
           }
        }

        window.onload = load;
      }
    end
  end
end

module M::Views
  def layout
    xhtml_transitional do
      head do
        title "Messages"
        link :rel => 'stylesheet', :type => 'text/css', :href => '/style.css', :media => 'screen'
        script :src => "js.js", :type => "text/javascript"
      end
      body do
        table do
          tr do
            td do
              self << yield
            end
          end
        end
      end
    end
  end
  
  def index
    div.desc! do
      text "Ever wanted to <strong>really</strong> give someone the message? Now you can. Enter a message (be terse), give the recipient the generated link, and they'll get the message in stark black-on-white. "
      a :href => "/list" do
        text "See everybody's messages"
      end
    end
    _create
  end
  
  def show
    text @message
  end
  
  def list
    @messages.each do |message|
      id = message === @messages.last ? "list_last" : nil
      div :id => id, :class => "list_message" do
        text message.message
      end
    end
  end
  
  def created
    text "link to message: "
    a :href => "http://m.bloople.net/#{@message.mhash}" do
      text "http://m.bloople.net/#{@message.mhash}"
    end
  end

  def _create
    form :action => "/create", :method => "post" do
      input.create_message! :name => "message"
    end
  end
end

def M.create
  M::Models.create_schema
  ActiveRecord::Base.default_timezone = :utc
end