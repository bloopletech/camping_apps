require 'htmlentities/string'

Camping.goes :JN2T

module JN2T::Controllers
  class Index < R '/'
    def get
      unless input.empty?
        @kanji_reading, @romaji_reading = reading(input.number)
        render :translation
      else
        render :index
      end
    end
  end

  class Translate < R '/(.+)'
    def get(num)
      @kanji_reading, @romaji_reading = reading(num)      
    end
  end
end

module JN2T::Helpers
  ZERO_TO_TEN_KANJI = %w( 〇 一 二 三 四 五 六 七 八 九 十)
  ZERO_TO_TEN_ROMAJI = %w(zero ich ni san yon go roku nana hachi kyū jū).reverse
  PREFIXES_KANJI = %w(万 億 兆 京 垓 ������ 穣 溝 澗 正 載 極)
  PREFIXES_ROMAJI = %w(man oku chō kei gai jo jō kō kan sei sai goku).reverse
  
  def reading(number)
    number.gsub!(/[^0-9.]/, '')
    
    num, dec = number.split('.', 2)

    kanji = ''
    romaji = ''

    if num[0..0] == '-'
      output << 'negative '
      num = num[1..-1]
    elsif num[0..0] == '+'
      output << 'positive '
      num = num[1..-1]
    end

    if num[0..0] == '0'
      kanji << '〇'
      romaji << 'zero'
    else
      groups = num.rjust(120, '0').scan(/\d{4}/)
      puts groups
      groups.each_with_index do |group, z|
        kanji << parse4digits(group) << (z == 11 ? '' : PREFIXES_KANJI[z])
      end
    end
    puts "kanji: #{kanji}, romaji: #{romaji}"
    [kanji, romaji]
  end
end

module JN2T::Views
  def layout
    xhtml_transitional do
      head do
        title "Convert numbers into their Japanese reading"
        style :type => "text/css" do
          %{
            /* <![CDATA[ */
            * { margin: 0; padding: 0; font-family: "Lucida Grande", Helvetica, Arial, sans-serif; font-size: 100%; }
            body { background-color: #ffffff; color: #000000; padding: 1em; text-align: center; }
            h1 { font-size: 200%; margin: 0.5em 0 1em 0; }
            p { margin: 0 0 1em 0; }
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
        p.footer! { "Created by #{a "Brenton Fletcher", :href => "http://i.bloople.net"} in #{File.stat(__FILE__).size} bytes of code. <a href='mailto:&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;'>Email me</a>! Made on a #{a "Mac", :href => "http://apple.com"}. Powered by #{a "Ruby", :href => "http://rubyonrails.org"} on #{a "Camping", :href => "http://code.whytheluckystiff.net/camping/"}." }
      end
    end
  end

  def index
    h1 { "Convert number into Japanese kanji reading" }
    p { "This tool converts a number into it's non-formal Japanese kanji reading." }
    form :action => '/', :method => :get do
      input :name => :number, :type => :text
    end
  end

  def translation
    p { @kanji_reading }
    p { @romaji_reading }
  end
end