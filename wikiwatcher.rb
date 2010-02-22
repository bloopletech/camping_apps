# encoding: utf-8
#=begin 
require 'hpricot'
require 'htmlentities/string'
require 'net/http'
require 'date'

Camping.goes :WikiWatcher

module WikiWatcher::Models
  class Edit < Base
    def author_url
      "http://en.wikipedia.org/wiki/#{anonymous? ? "Special:Contributions/#{author.encode_entities}" : "User:#{author.encode_entities}"}"
    end

    def contribs_url
      "http://en.wikipedia.org/wiki/Special:Contributions/#{author.encode_entities}"
    end

    def diff_url
      "http://en.wikipedia.org/w/index.php?title=#{article.encode_entities}&curid=#{page_id}&diff=#{rev_id}&direction=prev"
    end
  end

  class CreateEdits < V 0.1
    def self.up
      create_table :wikiwatcher_edits, :force => true do |t|
        t.column :rev_id, :integer
        t.column :page_id, :integer
        t.column :article, :text
        t.column :summary, :text
        t.column :author, :text
        t.column :word_diff, :integer
        t.column :minor, :boolean
        t.column :new_page, :boolean
        t.column :anonymous, :boolean
        t.column :published, :datetime
      end
    end
  end
end

module WikiWatcher::Controllers
  class Index < R '/'
    def get
      @edits = Edit.find(:all, :order => 'id DESC', :limit => 10) || []
      @last = true
      render :index
    end
  end
  
  class From < R '/(\d+)'
    def get(from)
      @edits = Edit.find(:all, { :order => 'id DESC' }.merge((from == '0') ? { :limit => 10 } : { :conditions => ['id > ?', from] })) || []
      @last = false
      render :_from
    end
  end
end

module WikiWatcher::Views
  def layout
    xhtml_transitional do
      head do
        title "WikiWatcher"
        style :type => 'text/css' do
          %{
            /* <![CDATA[ */
            * { margin: 0; padding: 0; font-family: "Lucida Grande", Helvetica, Arial, sans-serif; font-size: 100%; }
            body { padding: 1em 1em 0 1em; font-size: 95%; }
            p { margin: 0 0 1em 0; }
            ul { margin: -0.5em 0 1em 0; padding-left: 2.5em; }
            li { margin: 0.1em; }
            h1 { margin: -1em -1em 0.1em -1em; padding: 1em; background-color: #0033CC; color: #ffffff; font-weight: bold; }
            h1 span { font-size: 200%; }
            h2 { margin: 1em 0; border-bottom: 2px solid #C98300; font-weight: bold; }
            h2 span { font-size: 115%; }
            #edits { border-collapse: collapse; width: 100%; }
            #edits td, #edits th { border-right: 1px solid #000000; border-bottom: 1px solid #000000; padding: 0.3em; line-height: 1.5em; vertical-align: top; }
            #edits th { background-color: #303030; color: #ffffff; border-right: 1px solid #808080; border-bottom: 1px solid #808080; font-weight: bold; }
            #edits .last_r { border-right: none; }
            #edits tr.last_b td { border-bottom: none; }
            #edits tr.new td, span.new { color: #008000; }
            #edits tr.minor, span.minor { color: #808080; }
            #edits td.details { text-align: center; }
            #footer { margin: 1.1em -1em -1em -1em; padding: 1em; background-color: #0033CC; color: #ffffff; }
            #footer a { color: #BFCFFF; }
            /* ]]> */
          }
        end
        script :type => "text/javascript" do
          %{
            // <![CDATA[
            var http = null;
            var tbody = null;

            function getEdits()
            {
               http.open("get", "/" + tbody.firstChild.getAttribute("id").substring(1), true);
               http.send(null);
            }

            window.onload = function()
            {
               http = !!(window.attachEvent && !window.opera) ? new ActiveXObject("Microsoft.XMLHTTP") : new XMLHttpRequest();
               tbody = document.getElementById("edits").childNodes[1];

               http.onreadystatechange = function()
               {
                 if(http.readyState == 4)
                 {
                    var results = eval(http.responseText);
                    if(!results) return;
                    for(var i = results.length - 1; i >= 0; i--)
                    {
                       var row = results[i];

                       var tr = tbody.insertRow(0);
                       if(row['id']) tr.setAttribute('id', row['id']);
                       tr.className = row['classes'];

                       tr.insertCell(-1).innerHTML = row['article_title'];
                       tr.insertCell(-1).innerHTML = row['edit_summary'];

                       var details = tr.insertCell(-1);
                       details.className = "details";
                       details.innerHTML = row['details'];

                       tr.insertCell(-1).innerHTML = row['word_diff'];

                       var author = tr.insertCell(-1);
                       author.className = "last_r";
                       author.innerHTML = row['author'];
                    }

                    while(tbody.rows.length > (results.length + 10)) tbody.deleteRow(-1);

                    for(var lasttr = tbody.lastChild; lasttr.nodeName != "TR"; lasttr = lasttr.previousSibling);
                    lasttr.className = "last_b";
                 }
              };

              window.setInterval("getEdits()", 30000);
           }
           // ]]>
          }
        end
      end
      body do
        self << yield
      end
    end
  end
  
  def index
    h1 { span { "WikiWatcher" } }

    h2 { span { "Introduction" } }
    p { "WikiWatcher shows #{a 'Wikipedia', :href => 'http://en.wikipedia.org'} changing in real-time. Every change to Wikipedia instantly shows up on this page; just sit back and watch to see the world's largest encyclopedia change!"}
    p { "Each change to wikipedia is called an 'edit'. The table below lists the most recent edits to Wikipedia:" }
    ul do
      li { "The first column is the name of the article that's been edited." }
      li { "The second column displays a summary of what was changed." }
      li { "You can get the details of exactly what was edited by using the 'edit details' link in the third column." }
      li { "The fourth column shows the difference in the word count of the article following this edit." }
      li { "The fifth column displays the username of the person who made the edit, with a link to all the contributions for that user." }
    end
    p { "This page will automatically add the latest changes to Wikipedia to the top of the table every 30 seconds. A #{span 'green edit', :class => 'new' } means that the edit is for a new page. A #{span 'grey edit', :class => 'minor' } means the edit is a minor edit." }

    h2 { span { "Edits" } }
    table.edits! do
      thead do
        tr do
          th { "article title" }
          th { "edit summary" }
          th { "edit&nbsp;details" }
          th { "word&nbsp;count" }
          th.last_r { "edit author" }
        end
      end
      tbody do
        _edits.each_with_index do |edit, i|
          tr_hash = { :class => edit[:classes] }
          tr_hash[:id] = "_#{edits[0].id}" if i == 0
          tr tr_hash do
            td { edit[:article_title] }
            td { edit[:edit_summary] }
            td.details { edit[:details] }
            td { edit[:word_diff] }
            td.last_r { edit[:author] }
          end
        end
      end
    end

    p.footer! { "Created by #{a "Brenton Fletcher", :href => "http://blog.bloople.net"} in #{File.stat(__FILE__).size} bytes of code. " +
     "<a href='mailto:&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;'>Email me</a>! Powered by " +
     "#{a "Ruby", :href => "http://ruby-lang.org"} on #{a "Camping", :href => "http://github.com/camping/camping/"}." }
  end

  def _from
    text _edits.to_json
  end

  def _edits(edits = @edits, last = @last)
    return [] if edits.length == 0

    out = []

    edits.each_with_index do |edit, i|
      classes = []
      classes << 'new' if edit.new_page?
      classes << 'minor' if edit.minor?
      classes << 'last_b' if last and edit == edits.last

      e = { :article_title => (a edit.article, :href => "http://en.wikipedia.org/wiki/#{edit.article}", :target => '_blank'),
       :edit_summary => (edit.summary.nil? ? '(none)' : edit.summary),
       :details => (edit.rev_id.nil? ? '(none)' : (a 'edit details', :href => edit.diff_url, :target => '_blank')),
       :word_diff => (edit.word_diff == 0 ? 'no change' : "#{edit.word_diff.abs} #{(edit.word_diff > 0 ? 'more' : (edit.word_diff < 0 ? 'less' : ''))}"),
       :author => (a edit.author, :href => edit.author_url, :target => '_blank') + (edit.anonymous? ? '' : " #{a '(contribs)', :href => edit.contribs_url, :target => '_blank'}"),
       :classes => classes.join(' ') }
      e[:id] = "_#{edit.id}" if i == 0

      out << e
    end

    out
  end
end


module WikiWatcher
  ::API_URL = "http://en.wikipedia.org/w/api.php"
  ::INITIAL_URL = API_URL + "?action=query&format=xml&list=recentchanges&rcnamespace=0&rcdir=older&rcprop=comment%7Cflags%7Ctimestamp%7Ctitle%7Csizes%7Cids%7Cuser&rctype=edit%7Cnew%7Clog"

  def self.get_latest
    begin
      edits = Models::Edit.find(:all, :select => 'id', :order => 'id DESC')
      Models::Edit.delete(edits[500..-1].map { |edit| edit.id }) if edits.length > 500

      from = edits.empty? ? nil : Models::Edit.find(:first, :order => 'id DESC').published

      uri = URI.parse(INITIAL_URL + "&rclimit=" + (edits.empty? ? "10" : "500&rcend=" << from.utc.xmlschema))
      http = Net::HTTP.new(uri.host)
      doc = Hpricot(http.get(uri.request_uri, { "User-Agent" => "WikiWatcher http://wikiwatcher.bloople.net/ i@bloople.net" }).body)

      edits = edits.empty? ? [] : Models::Edit.find_all_by_published(from.utc, :select => 'rev_id, page_id, published')
      (doc/:rc).reject { |edit| edits.detect { |e| e.rev_id == edit.attributes['revid'].to_i and e.page_id == edit.attributes['pageid'].to_i } }.to_a.reverse.each do |edit|
        Models::Edit.create(:article => edit.attributes['title'],
         :summary => (edit.attributes['comment'].blank? ? nil : parse_wikitext(edit.attributes['comment'], edit.attributes['title'])),
          :author => edit.attributes['user'], :rev_id => edit.attributes['revid'], :page_id => edit.attributes['pageid'],
           :anonymous => edit.attributes.key?('anon'), :word_diff => (edit.attributes['newlen'].to_i - edit.attributes['oldlen'].to_i),
            :published => Time.xmlschema(edit.attributes['timestamp']), :minor => edit.attributes.key?('minor'), :new_page => edit.attributes.key?('new')).id
      end
    rescue Exception => e
    end

    nil
  end

  private
  def self.parse_wikitext(str, title)
    return str if str.scan(/\[\[/).length != str.scan(/\]\]/).length
    str.gsub(/\/\*(.*?)\*\//) { |match| " [[#{"#{title}##{$1.strip}"}|→ #{$1.strip}]]#{!$'.blank? ? ':' : ''} " }.encode_entities.gsub(/\[\[(.*?)\]\]/) do |match|
      to, name = ($1.include?('|') ? $1.split('|', 2) : [$1, $1])
      "<a href=\"http://en.wikipedia.org/wiki/#{to}\" target=\"_blank\">#{name}</a>"
    end.gsub(/ +/, ' ')
  end
end

def WikiWatcher.create
  WikiWatcher::Models.create_schema
  ActiveRecord::Base.connection.execute("DELETE FROM wikiwatcher_edits;")
  ActiveRecord::Base.default_timezone = :utc
#=begin
  Thread.new do
    while(true)
      z = Time.now
      puts "Getting latest"
      get_latest
      puts "Got latest, elapsed #{Time.now - z}"
      sleep(30)
    end
  end
#=end 
end
#=end