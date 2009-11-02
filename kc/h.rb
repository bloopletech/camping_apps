module Kc::Helpers
  def add_success(msg)
    @state[:flash] = { :success => [], :errors => [] } unless @state.key? :flash
    @state[:flash][:success] << msg
  end
  def add_error(msg)
    @state[:flash] = { :success => [], :errors => [] } unless @state.key? :flash
    @state[:flash][:errors] << msg
  end

  def label_for name, record = nil, attr = name, options = {}
    errors = record && !record.valid? && record.errors.on(attr)
    label name.to_s.humanize, { :for => name }, options.merge(errors ? { :class => :error } : {})
  end



  # login system
  def current_user
    @current_user ||= Kc::Models::User.find(@state.user_id) unless @state.user_id.blank?
  end
  alias logged_in? current_user
  
  def login name, password
    @current_user = Kc::Models::User.find_by_name_and_crypt input.name, input.password
    @state.user_id = @current_user.id if @current_user
  end
  
  def logout
    @state.user_id = nil
  end

  def ensure_logged_in
    unless logged_in?
      add_error("You must be logged in to do that.")
      redirect '/'
    end
    logged_in?
  end

  def admin?
    current_user.id == 1
  end


  def nice_date_time(date)
    return date.utc.strftime("%d/%m/%Y %I:%M%p")
  end

  def h(text)
    CGI::escapeHTML(text)
  end

  def large_avatar(user)
    user.has_avatar? ? (img :src => user.avatar_large_url, :class => 'avatar') : ''
  end

  def small_avatar(user)
    user.has_avatar? ? (img :src => user.avatar_small_url, :class => 'avatar') : ''
  end

  def image_column(record, name)
    has_file = record.send("has_#{name}?")
    out = "<div class='upload'>#{has_file ? img(:src => record.send("#{name}_url")) : ""}<div>"
    out << "#{input :type => :radio, :name => "has_#{name}", :value => '0', :onclick => "$('#{name}').disabled = true;", :class => 'radio'} No file<br />"
    out << "#{input :type => :radio, :name => "has_#{name}", :value => '1', :onclick => "$('#{name}').disabled = true;", :class => 'radio', :checked => 'checked'} Keep same file<br />" if has_file
    attrs = { :type => :radio, :name => "has_#{name}", :value => '1', :onclick => "$('#{name}').disabled = false;", :class => 'radio' }
    attrs[:checked] = "checked" if !has_file
    out << "#{input attrs} Upload new file"
    attrs = { :type => :file, :name => name, :id => name, :class => 'file' }
    attrs[:disabled] = "disabled" if has_file
    attrs[:checked] = "checked" if !has_file
    out << "#{input attrs}</div><div class='clear'></div></div>"
    out
  end

  def number_with_delimiter(number, delimiter=",", separator=".")
     begin
       parts = number.to_s.split('.')
       parts[0].gsub!(/(\d)(?=(\d\d\d)+(?!\d))/, "\\1#{delimiter}")
       parts.join separator
     rescue
       number
     end
   end
end