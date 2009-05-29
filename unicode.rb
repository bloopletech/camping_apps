# encoding: utf-8

require 'htmlentities/string'

Camping.goes :Unicode

module Unicode
  PATH = File.expand_path(File.dirname(__FILE__)) + '/unicode'
  def self.load_mapping
    if $mapping.empty?
      IO.readlines(Unicode::PATH + "/unicode.txt").each do |line|
        code_point, name = line.strip.split("\t")
        $mapping[code_point] = name
      end
    end
  end
end

module Unicode::Controllers
  class Index < R '/'
    def get
      Unicode.load_mapping
      @code_point = $mapping.keys[rand($mapping.keys.length)]
      render :index
    end
  end
  class Single < R '/([A-z0-9]+)'
    def get(code_point)
      Unicode.load_mapping
      @code_point = code_point.upcase
      render :index
    end
  end
end

module Unicode::Views
  def layout
    xhtml_transitional do
      head do
        title "Random Unicode Character"
        style :type => "text/css" do
          %{
            /* <![CDATA[ */
            * { margin: 0; padding: 0; font-family: "Lucida Grande", Helvetica, Arial, sans-serif; font-size: 100%; }
            body { background-color: #ffffff; color: #000000; padding: 1em; text-align: center; }
            h1 { font-size: 200%; margin: 0.5em 0 1em 0; }
            p { margin: 0 0 1em 0; }
            a { color: #0000ff; }
            #code_point { font-size: 300%; margin-bottom: 0.5em; }
            #name { font-size: 150%; }
            #note { font-size: 70%; width: 40em; margin: 0 auto 1em auto; } 
            #footer { margin: 1em; font-size: 90%; }
            /* ]]> */
          }
        end
      end
      body do
        self << yield
        p.footer! { "Created by #{a "Brenton Fletcher", :href => "http://i.bloople.net"} in #{File.stat(__FILE__).size} bytes of code. <a href='mailto:&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;'>Email me</a>! Powered by #{a "Ruby", :href => "http://rubyonrails.org"} on #{a "Camping", :href => "http://code.whytheluckystiff.net/camping/"}." }
      end
    end
  end

  def index
    h1 { "Random Unicode Character" }
    p.code_point! { "&#x#{@code_point};" }
    p.name! { "#{$mapping[@code_point]} (<a href='/#{@code_point}'>#{@code_point}</a>)" }
    p.note! { "Does not include the ranges CJK Ideograph Extension A, CJK Ideograph Extension B, CJK Ideograph, Hangul Syllable, Non Private Use High Surrogate, Private Use High Surrogate, Low Surrogate, High Surrogate, Private Use, Plane 15 Private Use, Plane 16 Private Use." }
  end

end

def Unicode.create
  $mapping = {}
end