require 'markaby/tags'

module Markaby
  # The Markaby::Builder class is the central gear in the system.  When using
  # from Ruby code, this is the only class you need to instantiate directly.
  #
  #   mab = Markaby::Builder.new
  #   mab.html do
  #     head { title "Boats.com" }
  #     body do
  #       h1 "Boats.com has great deals"
  #       ul do
  #         li "$49 for a canoe"
  #         li "$39 for a raft"
  #         li "$29 for a huge boot that floats and can fit 5 people"
  #       end
  #     end
  #   end
  #   puts mab.to_s
  #
  class Builder

    @@default = {
      :indent => 0,
      :output_helpers => true,
      :output_xml_instruction => true,
      :output_meta_tag => true,
      :auto_validation => true,
      :tagset => Markaby::XHTMLTransitional
    }

    def self.set(option, value)
      @@default[option] = value
    end

    def self.ignored_helpers 
      @@ignored_helpers ||= [] 
    end 
 
    def self.ignore_helpers(*helpers) 
      ignored_helpers.concat helpers 
    end 

    attr_accessor :output_helpers, :tagset

    # Create a Markaby builder object.  Pass in a hash of variable assignments to
    # +assigns+ which will be available as instance variables inside tag construction
    # blocks.  If an object is passed in to +helpers+, its methods will be available
    # from those same blocks.
    #
    # Pass in a +block+ to new and the block will be evaluated.
    #
    #   mab = Markaby::Builder.new {
    #     html do
    #       body do
    #         h1 "Matching Mole"
    #       end
    #     end
    #   }
    #
    def initialize(assigns = {}, helpers = nil, &block)
      @streams = [[]]
      @assigns = assigns
      @elements = {}

      @@default.each do |k, v|
        instance_variable_set("@#{k}", @assigns[k] || v)
      end

      if helpers.nil?
        @helpers = nil
      else
        @helpers = helpers.dup
        for iv in helpers.instance_variables
          instance_variable_set(iv, helpers.instance_variable_get(iv))
        end
      end

      unless assigns.nil? || assigns.empty?
        for iv, val in assigns
          instance_variable_set("@#{iv}", val)
          unless @helpers.nil?
            @helpers.instance_variable_set("@#{iv}", val)
          end
        end
      end

      @builder = ::Builder::XmlMarkup.new(:indent => @indent, :target => @streams.last)
      class << @builder
          attr_accessor :target, :level
      end
      
      @contents = []
      @return_as_string = true

      if block
        text(capture(&block))
      end
    end

    # Returns a string containing the HTML stream.  Internally, the stream is stored as an Array.
    def to_s
      @streams.last.to_s
    end

    # Write a +string+ to the HTML stream without escaping it.
    def text(string)
      puts "text called"
      @contents.last << "#{string}"
      nil
    end
    alias_method :<<, :text
    alias_method :concat, :text

    # Emulate ERB to satisfy helpers like <tt>form_for</tt>.
    def _erbout; self end

    # Captures the HTML code built inside the +block+.  This is done by creating a new
    # stream for the builder object, running the block and passing back its stream as a string.
    #
    #   >> Markaby::Builder.new.capture { h1 "TEST"; h2 "CAPTURE ME" }
    #   => "<h1>TITLE</h1>\n<h2>CAPTURE ME</h2>\n"
    #
    def capture(&block)
      puts "capture started"
      @contents.push("")
      old_return_as_string = @return_as_string
      @return_as_string = false
      instance_eval(&block)
      @return_as_string = old_return_as_string
      puts "capture ended"
      @contents.pop
    end

    # Create a tag named +tag+. Other than the first argument which is the tag name,
    # the arguments are the same as the tags implemented via method_missing.
    def tag!(tag, *args, &block)
      puts "tag! called: #{tag}, #{args.inspect}, return_as_string: #{@return_as_string.inspect}"
      puts "self: #{self.inspect}, #{self.class.inspect}"
      inner = nil
      if args.length == 2
        inner = args[0]
        args = args[1]
      elsif args.length == 1
        args = args[0]
      else
        args = {}
      end

      @contents.push(Fragment.new("", @contents.length))
      
      @contents.last << "<#{tag} #{args.map { |(k, v)| "#{k}='#{v}'" }.join(' ')}>"
      puts "cl: #{@contents.last}"
      if block_given?
        old_return_as_string = @return_as_string
        @return_as_string = false
        instance_eval(&block)
        @return_as_string = old_return_as_string
      elsif !inner.nil?
        @contents.last << inner
      end
      @contents.last << "</#{tag}>"
      puts "cl: #{@contents.last}"

      return @contents.last
=begin
      ele_id = nil
      if block
        inner = capture &block
      else
        inner = ""
      end
      
      @content += "<#{tag} #{args.map { |(k, v)| "#{k}='#{v}'" }.join(' ')}>#{inner}</#{tag}>"
=end
    end

    attr_reader :builder

    # This method is used to intercept calls to helper methods and instance
    # variables.  Here is the order of interception:
    #
    # * If +sym+ is a helper method, the helper method is called
    #   and output to the stream.
    # * If +sym+ is a Builder::XmlMarkup method, it is passed on to the builder object.
    # * If +sym+ is also the name of an instance variable, the
    #   value of the instance variable is returned.
    # * If +sym+ has come this far and no +tagset+ is found, +sym+ and its arguments are passed to tag!
    # * If a tagset is found, though, +NoMethodError+ is raised.
    #
    # method_missing used to be the lynchpin in Markaby, but it's no longer used to handle
    # HTML tags.  See html_tag for that.
    def method_missing(sym, *args, &block)
      puts "sym: #{sym}, args: #{args.inspect}"
      puts "caller: #{caller.inspect}"
      if @helpers.respond_to?(sym, true) && !self.class.ignored_helpers.include?(sym)
        puts "got a helper"
        r = @helpers.send(sym, *args, &block)
        if @output_helpers and r.respond_to? :to_str
          @contents.last << r
        else
          puts "r: #{r}"
          r
        end
      elsif instance_variables.include?("@#{sym}")
        puts "got an instance var"
        instance_variable_get("@#{sym}")
      else
        tag!(sym.to_s, *args, &block)
=begin        
        if sym != :class_eval
          class_eval %{
            def #{sym.to_s}(*args, &block)
              tag!(#{sym.to_s}, *args, &block)
            end
          }
        end
        tag!(sym, *args, &block)
=end
      end
    end
=begin
    XHTMLTransitional.tags.each do |k|
      class_eval %{
        def #{k}(*args, &block)
          tag!(#{k.inspect}, *args, &block)
        end
      }
    end
=end

    # Every HTML tag method goes through an html_tag call.  So, calling <tt>div</tt> is equivalent
    # to calling <tt>html_tag(:div)</tt>.  All HTML tags in Markaby's list are given generated wrappers
    # for this method.
    #
    # If the @auto_validation setting is on, this method will check for many common mistakes which
    # could lead to invalid XHTML.
    def html_tag(sym, *args, &block)
      if args.empty? and block.nil? and not NO_PROXY.include?(sym)
        return CssProxy.new do |args, block|
          if @tagset.forms.include?(sym) and args.last.respond_to?(:to_hash) and args.last[:id]
            args.last[:name] ||= args.last[:id]
          end
          tag!(sym, *args, &block)
        end
      end
      if not @tagset.nil? and !@tagset.self_closing.include?(sym) and args.first.respond_to?(:to_hash)
        block ||= proc{}
      end
      tag!(sym, *args, &block)
    end

    XHTMLTransitional.tags.each do |k|
      class_eval %{
        def #{k}(*args, &block)
          html_tag(#{k.inspect}, *args, &block)
        end
      }
    end

    # Builds a head tag.  Adds a <tt>meta</tt> tag inside with Content-Type
    # set to <tt>text/html; charset=utf-8</tt>.
    def head(*args, &block)
      puts "head"
      tag!(:head, *args) do
        tag!(:meta, "http-equiv" => "Content-Type", "content" => "text/html; charset=utf-8") if @output_meta_tag
        instance_eval(&block)
      end
    end

    # Builds an html tag.  An XML 1.0 instruction and an XHTML 1.0 Transitional doctype
    # are prepended.  Also assumes <tt>:xmlns => "http://www.w3.org/1999/xhtml",
    # :lang => "en"</tt>.
    def xhtml_transitional(&block)
      puts "xhtml_transitional"
      self.tagset = Markaby::XHTMLTransitional
      xhtml_html &block
    end

    # Builds an html tag with XHTML 1.0 Strict doctype instead.
    def xhtml_strict(&block)
      self.tagset = Markaby::XHTMLStrict
      xhtml_html &block
    end

    private

    def xhtml_html(&block)
      #instruct! if @output_xml_instruction
      @contents.last << '<!DOCTYPE html PUBLIC "-//W3C//DTD XHTML 1.1//EN" "http://www.w3.org/TR/xhtml11/DTD/xhtml11.dtd">'
      tag!(:html, :xmlns => "http://www.w3.org/1999/xhtml", "xml:lang" => "en", :lang => "en", &block)
    end

    def fragment
      stream = @streams.last
      f1 = stream.length
      yield
      f2 = stream.length - f1
      Fragment.new(stream, f1, f2)
    end

  end
  class Fragment < String
    def to_s
      
=begin 
  # Every tag method in Markaby returns a Fragment.  If any method gets called on the Fragment,
  # the tag is removed from the Markaby stream and given back as a string.  Usually the fragment
  # is never used, though, and the stream stays intact.
  #
  # For a more practical explanation, check out the README.
  class Fragment < ::Builder::BlankSlate
    def initialize(s, a, b)
      @s, @f1, @f2 = s, a, b 
    end
    def method_missing(*a)
      unless @str
        @str = @s[@f1, @f2].to_s  
        @s[@f1, @f2] = [nil] * @f2
        @str
      end
      @str.send(*a)
    end
  end
=end
end
