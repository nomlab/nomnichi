# coding: utf-8
# Scopes added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base # :nodoc:
  # helper :all # include all helpers, all the time
  protect_from_forgery with: :exception

  # Scrub sensitive parameters from your log
  # scope_parameter_logging :password
  prepend_before_filter :login_state_setup
  before_filter :authenticate, except: :rescue_404

  def rescue_404
    absolute_root = File.join(File.expand_path(Rails.root), '')
    template = File.expand_path(File.join('public_html', params[:path]), Rails.root)
    template << "." + params[:format] if params[:format].present?

    if template.index(absolute_root) == 0
      if File.directory?(template) and /\/\z/ !~ request.original_fullpath
        return redirect_to(request.original_fullpath + "/")
      end

      if /\/\z/ =~ request.original_fullpath
        ['.html.erb', '.erb', '.rhtml', '.html'].each do |ext|
          if File.file?(template+'/index'+ ext)
            template = template + '/index' + ext
            break
          end
        end
      end

      ['.html.erb', '.erb', '.rhtml', '.html'].each do |ext|
        return render(:file => template+ext,
                      :layout => 'application') if File.file?(template+ext)
      end

      if template =~ /\.html$/ and File.file?(template)
        return render(:file => template, :layout => 'application')
      end

      if template =~ /\.txt$/ and File.file?(template)
        return send_file(template, :type => 'text/plain',
                         :disposition => 'inline')
      end

      if File.file?(template)
        return send_file(template)
      end
    end
    render :file => File.join(Rails.root,  'public_html', '404.html')
  end

  private
  def escape_javascript(string)
    ApplicationController.helpers.escape_javascript(string)
  end

  def render_partial_html(url,locals)
    old_formats = formats
    self.formats = [:html]
    html = render_to_string :partial => url[:action], :locals => locals
    self.formats = old_formats
    return html
  end

  def reset_page
    if /\A(.+)(\?page=\d+)\z/ =~ request.headers["Referer"]
      request.headers["Referer"] = $1
    end
  end

  def login_state_setup
    if session[:user_id]
      User.current = User.find(session[:user_id]) rescue nil
    else
      User.current = nil
    end
    return true
  end

  def authenticate
    return true if User.current

    session[:jumpto] = request.parameters
    redirect_to :controller => "gate", :action => "login"
    return false
  end

  def set_current_user(user)
    session[:user_id] = user.id
    User.current = user
  end

  def reset_current_user
    session[:user_id] = nil
    User.current = nil
  end

  def set_omniauth_info(auth)
    session[:provider]   = auth["provider"]
    session[:uid]        = auth["uid"]
    session[:avatar_url] = auth["info"]["image"]
  end

  def authenticate_with_omniauth
    return true if session[:provider] && session[:uid] && session[:avatar_url]

    flash[:warning] = "User not omniauthed cannot create user."
    redirect_to root_path
    return false
  end

  def reset_session_expires
    Rails.application.config.session_options[:session_expires] = 1.month.from_now
  end
end
