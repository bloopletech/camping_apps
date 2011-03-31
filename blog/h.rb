module Blog::Helpers
  def add_success(msg)
    @state[:flash] = { :success => [], :errors => [] } unless @state.key? :flash
    @state[:flash][:success] << msg
  end
  def add_error(msg)
    @state[:flash] = { :success => [], :errors => [] } unless @state.key? :flash
    @state[:flash][:errors] << msg
  end

  # login system
  def current_user
    @current_user ||= Blog::Models::Admin.find(@state.admin_id) unless @state.admin_id.blank?
  end
  alias logged_in? current_user

  def login name, password
    @current_user = Blog::Models::Admin.find_by_name_and_password input.name, input.password
    @state.admin_id = @current_user.id if @current_user
  end

  def logout
    @state.admin_id = nil
  end

  # menu bar
  def menu target = nil
    if target
      args = target.is_a?(Symbol) ? [] : [target]
      for role, submenu in menu[target].sort_by { |k, v| [:visitor, :admin].index k }
        ul.menu.send(role) do
          submenu.each do |x|
            liopts = (x == submenu.last) ? { :class => 'last' } : { }
            li(liopts) { x[/\A\w+\z/] ? a(x, :href => R(Blog::Controllers.const_get(x), *args)) : x }
          end
        end unless submenu.empty?
      end
    else
      @menu ||= Hash.new { |h, k| h[k] = { :visitor => [], :admin => [] } }
    end
  end

  # shortcut for error-aware labels
  def label_for name, record = nil, attr = name, options = {}
    errors = record && !record.body.blank? && !record.valid? && record.errors.on(attr)
    label name.to_s.humanize, { :for => name }, options.merge(errors ? { :class => :error } : {})
  end

  # find all tags
  def tags
    Blog::Models::Post.find(:all, :select => 'DISTINCT tags').map(&:tags).join(' ').split(/\s+/).uniq
  end

  def ellipsis(content)
    t = content.split(/\s+/)
    t[0...10].join(' ') + (t.length > 10 ? "..." : "")
  end

  def h(text)
    CGI::escapeHTML(text)
  end

  #implicitly html-escapes the input
  def wbrize(s)
    s.scan(/.{1,15}/).map { |c| h c }.join("<wbr />")
  end

  def nice_date_time(dt)
    dt.in_time_zone('Adelaide').strftime('%I:%M %p on %A, %d/%m/%Y')
  end
end