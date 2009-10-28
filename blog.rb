# encoding: utf-8
%w(redcloth camping/ar camping/session image_science lib/common).each { |lib| require lib }

# Fix unicode urls
$KCODE = 'u'

Camping.goes :Blog

module Blog; VERSION = 0.99
  include Camping::Session
  PATH = File.expand_path(File.dirname(__FILE__)) + '/blog'

  def self.create
    Blog::Models.create_schema :assume => (Blog::Models::Post.table_exists? ? 1.0 : 0.0)
    ActiveRecord::Base.default_timezone = :utc
  end

  #TODO: Used? If so, change so HTML 4, otherwise drop this cod
  # beautiful XHTML 11
  class Mab
    def xhtml11(&block)
      self.tagset = Markaby::XHTMLStrict
      declare! :DOCTYPE, :html, :PUBLIC, '-//W3C//DTD XHTML 1.1//EN', 'http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd'
      tag!(:html, :xmlns => 'http://www.w3.org/1999/xhtml', 'xml:lang' => 'en', &block)
      self
    end
  end
end

require 'blog/m'
require 'blog/c'
require 'blog/h'
require 'blog/v'