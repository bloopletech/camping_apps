require 'net/http'
require 'json/add/rails'

Camping.goes :WW2

module WW2::Base
  alias_method :orig_initialize, :initialize
  def initialize(r, e, m)
    orig_initialize(r, e, m)
    @root = ''
  end
end

module WW2::Models
  class X < Base; end
  def self.get_edits(from)
    JSON.parse(Net::HTTP.get(URI.parse("http://wikiwatcher.bloople.net/#{from}")))
  end
end

module WW2::Controllers
  class Index < R '/'
    def get
      @edits = Models.get_edits(0) || []
      render :index
    end
  end
  
  class From < R '/(\d+)'
    def get(from)
      @edits = Models.get_edits(from) || []
      render :_from
    end
  end
end

module WW2::Views
  def layout
    xhtml_transitional do
      head do
        title "WikiWatcher2"
        style :type => 'text/css' do
          %{
            /* <![CDATA[ */
            * { margin: 0; padding: 0; font-family: Impact, sans-serif; font-size: 100%; color: #000; background-color: #fff; }
            body { padding: 0.1em; font-size: 1.5em; line-height: 1.1; }
            a { text-decoration: none; color: #00f; }
            /* ]]> */
          }
        end
        script :type => "text/javascript" do
          %{
            // <![CDATA[
            var http = null;
            var p = null;

            function getEdits()
            {
               http.open("get", "/" + p.firstChild.getAttribute("id").substring(1), true);
               http.send(null);
            }

            window.onload = function()
            {
               http = !!(window.attachEvent && !window.opera) ? new ActiveXObject("Microsoft.XMLHTTP") : new XMLHttpRequest();
               p = document.getElementById('p');
               http.onreadystatechange = function() { if(http.readyState == 4) p.innerHTML = http.responseText + p.innerHTML; };
               window.setInterval("getEdits()", 30000);
           }
           // ]]>
          }
        end
      end
      body do
        p.p! do
          self << yield
        end
      end
    end
  end
  
  def index
    _edits(@edits)
  end

  def _from
    _edits(@edits) + ' •••• '
  end

  def _edits(edits = @edits)
    return "" if edits.empty?
    "<span id='#{edits[0]['id']}'></span>" + edits.map { |edit| "#{edit['article_title']} • #{edit['edit_summary']} • #{edit['details']} • #{edit['word_diff']} • #{edit['author']}" }.join(' •••• ')
  end
end