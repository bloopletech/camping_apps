# require 'rubygems'
# require 'mongrel'
# require 'camping'
# require 'htmlentities/string'
# require 'digest/md5'
# require 'open-uri'
# require 'thread'
# require 'json'
# 
# class PoolingExecutor
#   attr_reader :pool
# 
#   def initialize(pool_size)
#     @mutex = Mutex.new
#     @pool = (1..pool_size).to_a.map { Object.new }
#     @handleravail = ConditionVariable.new
#     @threads = {}
#   end
# 
#   def run
#     handler = nil
#     ref = []
#     @mutex.synchronize do
#       @handleravail.wait @mutex until @pool.size > 0 if @pool.size == 0
#       handler = @pool.shift
#       @threads[handler] = ref
#     end
#     ref << Thread.new do
#       begin
#         yield
#       ensure
#         @mutex.synchronize do
#           @pool << handler
#           @threads.delete handler
#           @handleravail.signal
#         end
#       end
#     end
#     ref[0]
#   end
# 
#   def wait_for_all
#     @threads.each_value do |thread|
#       begin
#         thread[0].join 
#       rescue Exception
#       end
#     end
#     @threads.clear
#   end
# 
#   def num_tasks
#     @threads.size
#   end
# end
# 
# 
# 
# 
# 
# 
# Camping.goes :Comicpull
# 
# module Comicpull::Base
#   alias_method :initialize_without_rootfix, :initialize
#   def initialize_with_rootfix(env)
#     initialize_without_rootfix(env)
#     @root = ''
#   end
#   alias_method :initialize, :initialize_with_rootfix
# end
# 
# module Comicpull::Models
#   class ComicSource
#   end
# 
#   class ScrapeComicSource < ComicSource
#     @@scrapers = []
# 
#     attr_reader :source_url, :regex
# 
#     def initialize(source_url, regex, prefix = "", suffix = "")
#       @source_url = source_url
#       @regex = regex
#       @prefix = prefix
#       @suffix = suffix
# 
#       @@scrapers << self
#     end
# 
#     def comic_url
#       if @_comic_url.nil?
#         executor = PoolingExecutor.new(10)
#         @@scrapers.each do |scraper|
#           executor.run do
#             content = ''
#             open(scraper.source_url) { |is| content << is.read(10240) until is.eof? }
#             scraper.process(content)
#             @@scrapers.delete(scraper)
#           end
#         end
# 
#         executor.wait_for_all
#       end
# 
#       @_comic_url
#     end
# 
#     protected
#     def process(content)
#       content =~ @regex
#       @_comic_url = @prefix + ($1 ? $1 : "") + @suffix
#     end
#   end
# end
# 
# module Comicpull::Controllers
#   class Index < R '/'
#     def get
#       render :index
#     end
#   end
#   class MetaData < R '/metadata'
#     def get
#       @comics = [ScrapeComicSource.new("http://www.questionablecontent.net/", /<img src="http:\/\/www.questionablecontent.net\/comics\/(.*?).png">/, "http://www.questionablecontent.net/comics/", ".png"),
#       ScrapeComicSource.new("http://xkcd.com/", /<img src="http:\/\/imgs.xkcd.com\/comics\/(.*?)" title=".*?" alt=".*?" \/><br\/>/, "http://imgs.xkcd.com/comics/"),
#       ScrapeComicSource.new("http://www.little-gamers.com/", /<div id="comic-middle"><img src="(.*?)" alt=".*?" title=".*?" \/><\/div>/),
#       ScrapeComicSource.new("http://www.whiteninjacomics.com/comics.shtml", /<img src=\/images\/comics\/(.*?).gif border=0> <!-- /, "http://www.whiteninjacomics.com/images/comics/", ".gif"),
#       ScrapeComicSource.new("http://www.penny-arcade.com/comic/", /<div class="simplebody"><img src="\/images\/(.*?)" alt=".*?" width=".*?" height=".*?" \/><\/div>/, "http://www.penny-arcade.com/images/"),
#       ScrapeComicSource.new("http://irregularwebcomic.net/", /<img src="\/comics\/(.*?)" width=.*? height=.*? alt="Comic #.*?">/, "http://irregularwebcomic.net/comics/"),
#       ScrapeComicSource.new("http://www.kawaiinot.com/", /<p id="cg_img"><img src="(.*?)" alt="End" \/><\/p>/, "http://www.kawaiinot.com/"),
#       ScrapeComicSource.new("http://www.hingos.com/patches/", /<img src="strip\/(.*?).gif">/, "http://www.hingos.com/patches/strip/", ".gif"),
#       ScrapeComicSource.new("http://wigu.com/", /<img src="(.*?)" alt="">  <br \/><br \/>/),
#       ScrapeComicSource.new("http://dilbert.com/fast/", /<img src="\/dyn\/str_strip\/(.*?)" \/>/, "http://dilbert.com/dyn/str_strip/"),
#       ScrapeComicSource.new("http://www.overcompensating.com/", /<img src="\/comics\/(.*?)" width=".*?" height=".*?" title=".*?" border="0" \/>/, "http://www.overcompensating.com/comics/"),
#       ScrapeComicSource.new("http://www.octopuspie.com/", /<td><a href="index.php?date="><img src="strippy\/(.*?)\.png" alt=".*?\.png" title=".*?"><\/a><\/td>/, "http://www.octopuspie.com/strippy/", ".png")]
# 
#       render :metadata
#     end
#   end
#   class Arrange < R '/arrange/(.+)'
#     def get(sizes)
#       sizes = sizes.split('|')
#       sizes.pop
#       sizes = sizes.map { |size| size.split(',') }
#       
#       #...
#     end
# end
# 
# module Comicpull::Views
#   def index
#     xhtml_transitional do
#       head do
#         title "Comics"
#         style :type => "text/css" do
#           %{/* <![CDATA[ */
#             * { margin: 0; padding: 0; }
#             body { background-color: #ffffff; color: #000000; margin: 5px; }
#             img { border: 0; display: block; position: absolute; }
#             #fbaa20bfa264ec5e0535c0bd917a02e9, #e892b1575af38b99c69ee5b00805c713 { float: right; }
#             /* ]]> */
#           }
#         end
#         script :type => "text/javascript" do
#           %{//<![CDATA[
#             var http = null;
#             var comics = [];
#             var sizes = [];
#             
#             window.onload = function()
#             {
#                http = !!(window.attachEvent && !window.opera) ? new ActiveXObject("Microsoft.XMLHTTP") : new XMLHttpRequest();
# 
#                http.onreadystatechange = function()
#                {
#                   if(http.readyState == 4)
#                   { 
#                      comics = eval(http.responseText);
#                      console.log(comics);
#                      for(var i = 0; i < comics.length; i++)
#                      {
#                         var img = new Image();
#                         img.src = urls[i].comic_url;
#                         comics[i].image = img;
#                         sizes.push({ width: img.width, height: img.height });
#                      }
#                      
#                      
#                      
#                      
#                      for(var i = 0; i < comics.length; i++)
#                      {
#                         output += "<a href='" + comics[i].site_url + "'><img src='" + comics[i].comic_url + "' style='left: " + positions[i].left + "px; top: " + positions[i].top + "px'></a>";
#                      var size_str = "";
#                      for(var i = 0; i < sizes.length; i++) size_str += sizes[i].width + "," + sizes[i].height + "|";
# 
#                      http.open("get", "/arrange/" + size_str, true);
#                      http.onreadystatechange = function()
#                      {
#                         if(http.readyState == 4)
#                         {
#                            alert(http.responseText);
#                            var positions = eval(http.responseText);
#                            var output = "";
#                            for(var i = 0; i < positions.length; i++)
#                            {
#                               
#                            }
#                            document.body.innerHTML = output;
#                         }
#                      };
#                      http.send(size_str);
#                   }
#                }
#                http.open("get", "/metadata", true);
#                http.send(null);
#             }
#             //]]>
#           }
#         end
#       end
#       body do
#         p { "Loading..." }
#       end
#     end
#   end
# 
#   def metadata
#     @comics.map { |c| { :source_url => c.source_url, :comic_url => c.comic_url, :id => Digest::MD5.hexdigest(c.source_url), :image => nil } }.to_json
#   end
# 
#   def arrange
#     @comics.map { |c| { } }.to_json
#   end
# end