module Watchlist::Helpers
  include WillPaginate::ViewHelpers

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
    @current_user ||= Watchlist::Models::User.find(@state.user_id) unless @state.user_id.blank?
  end
  alias logged_in? current_user
  
  def login name, password
    @current_user = Watchlist::Models::User.find_by_name_and_password input.name, input.password
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


  def nice_date(date)
    return date.strftime("%d/%m/%Y")
  end

  def h(text)
    CGI::escapeHTML(text)
  end

  def ue(text)
    CGI::escape(text)
  end

  def gs(text)
    "<a href='http://www.google.com/search?q=#{CGI::escape(text)}' target='_blank'>#{h text}</a>"
  end

  def gs_title(title)
    titles = []
    titles << "#{gs(title.title_romaji_main + " " + title.title_romaji_suffix)} (romaji)" unless title.title_romaji.blank?
    titles << "#{gs(title.title_english_main + " " + title.title_english_suffix)} (english)" unless title.title_english.blank?
    titles << "#{gs(title.title_japanese_main + " " + title.title_japanese_suffix)} (japanese)" unless title.title_japanese.blank?
    titles2 = []
    titles2 << "#{gs(title.title_romaji_main)} (romaji)" unless title.title_romaji.blank?
    titles2 << "#{gs(title.title_english_main)} (english)" unless title.title_english.blank?
    titles2 << "#{gs(title.title_japanese_main)} (japanese)" unless title.title_japanese.blank?
    "<p>Google search for #{titles.join(', ')}, or just #{titles2.join(', ')}.</p>"
  end
end