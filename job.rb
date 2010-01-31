# encoding: utf-8

Camping.goes :Job

module Job::Controllers
  class Index < R '/'
    def get
      render :index
    end
  end
  
  class Small < R '/small' #5min - 1hr
    def get
      @duration = rand(12) * 5 + 5
      render :result
    end
  end

  class Medium < R '/medium' #1hr - 16hr
    def get
      @duration = rand(33) * 30 + 60
      render :result
    end
  end

  class Large < R '/large' #16hr - 60hr
    def get
      @duration = rand(45) * 60 + (16 * 60)
      render :result
    end
  end
end

module Job::Helpers
  def ddate(duration)
    diff = (duration * 60)
    out = []

    if diff >= (60 * 60)
      c = (diff / (60 * 60.0)).floor
      out << "#{c} hour#{c != 1 ? 's' : ''}"
      diff -= (60 * 60) while diff >= (60 * 60)
    end
    if diff >= 60
      c = (diff / 60.0).floor
      out << "#{c} minute#{c != 1 ? 's' : ''}"
    end

    out.join(' ')
  end
end

module Job::Views
  def layout
    xhtml_transitional do
      head do
        title "Job length generator"
        style :type => "text/css" do
          %{
            /* <![CDATA[ */
            * { margin: 0; padding: 0; font-family: "Lucida Grande", Helvetica, Arial, sans-serif; font-size: 100%; }
            body { background-color: #ffffff; color: #000000; text-align: center; padding: 1em; font-size: 150%; }
            h1 { font-size: 160%; margin-bottom: 1em; }
            p { margin-bottom: 1em; }
            #footer { position: absolute; bottom: 0; left: 0; font-size: 50%; margin-bottom: 0; }
            /* ]]> */
          }
        end
      end
      body do
        h1 { "Job length generator" }
        self << yield
        p { "Pick a job size: #{a 'small', :href => R(Small)} #{a 'medium', :href => R(Medium)} #{a 'large', :href => R(Large)}." }
        p.footer! { "Created by #{a "Brenton Fletcher", :href => "http://blog.bloople.net"} in #{File.stat(__FILE__).size} bytes of code. " +
         "<a href='mailto:&#105;&#064;&#098;&#108;&#111;&#111;&#112;&#108;&#101;&#046;&#110;&#101;&#116;'>Email me</a>! Powered by " +
         "#{a "Ruby", :href => "http://ruby-lang.org"} on #{a "Camping", :href => "http://github.com/camping/camping/"}." }
      end
    end
  end

  def index
  end

  def result
    p { ddate(@duration) }
  end
end