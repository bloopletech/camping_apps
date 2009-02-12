# encoding: utf-8

require 'htmlentities/string'

Camping.goes :B

module B::Models
  class Book
    @@books = []

    def initialize(title, author, pages)
      @title, @author, @pages = title, author, pages
      @@books << self
    end
    
    attr_reader :title, :author, :pages

    def url
      Book.url(title)
    end
    
    def self.url(title)
      title.to_s.downcase.gsub(/[^A-z0-9]/, '_')
    end
    
    def self.all
      @@books
    end
    
    def self.find_by_title(title)
      @@books.detect { |b| b.title == title }
    end

    def self.find_by_url(url)
      @@books.detect { |b| b.url == url }
    end
  end
end

module B::Controllers
  class Index < R '/'
    def get
      @books = Book.all
      render :index
    end
  end
  
  class Page < R '/(.+)/(.+)'
    def get(url, id)
      @book = Book.find_by_url(url)
      @page_id = id.to_i
      @page = @book.pages[@page_id - 1]
      render :page
    end
  end

  class Style < R '/style.css'
    def get
      @headers["Content-Type"] = "text/css; charset=utf-8"
      @body = %{
        body { background-color: #ffffff; color: #000000; margin: 0; padding: 0 1em; font-family: "Lucida Grande", Helvetica, Arial, sans-serif; }
        p, ul { margin: 1em 0; padding: 0; }
        ul { list-style-type: none; }
        h1 { margin: 0.7692em 0; padding: 0; font-size: 130%; }
      }
    end
  end

  class TOC < R '/(.+)'
    def get(url)
      @book = Book.find_by_url(url)
      render :toc
    end
  end
end

module B::Views
  def layout
    xhtml_transitional do
      head do
        title(!@book.nil? ? "#{@book.title} by #{@book.author}" : "Books")
        link :rel => 'stylesheet', :type => 'text/css', :href => '/style.css'
      end
      body do
        self << yield
      end
    end
  end

  def index
    h1 { "Books" }
    ul { @books.each { |b| li { a(b.title, :href => "/#{b.url}") } } }
    p { "Created by #{a "Brenton Fletcher", :href => "http://i.bloople.net"}." }
  end

  def toc
    h1 { "#{@book.title} by #{@book.author}" }
    ul { @book.pages.each_with_index { |p, i| li { a("Page #{i + 1}", :href => "/#{@book.url}/#{i + 1}") } } }
  end

  def page
    h1 { "#{@book.title} by #{@book.author} - Page #{@page_id}" }
    text @page
    pages = []
    pages << a('<< Previous page', :href => "#{@page_id - 1}") if @page_id > 1
    pages << a('Next page >>', :href => "#{@page_id + 1}") if @page_id < @book.pages.length
    p { pages.join(' | ') }
  end
end

def B.create
  Dir.glob("b/*.yml") do |filename|
    f = YAML.load_file(filename)
    B::Models::Book.new(f['title'].to_s, f['author'], f['parts'])
  end
end