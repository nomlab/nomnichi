# Scopes added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base # :nodoc:
  # helper :all # include all helpers, all the time
  protect_from_forgery with: :exception

  # Scrub sensitive parameters from your log
  # scope_parameter_logging :password
  prepend_before_filter :login_state_setup
  before_filter :authenticate

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

  def reset_session_expires
    Rails.application.config.session_options[:session_expires] = 1.month.from_now
  end
end
