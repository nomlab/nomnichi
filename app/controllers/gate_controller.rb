class GateController < ApplicationController
  skip_before_filter :authenticate

  def index
    redirect_to :controller => :welcome, :action => "index"
  end

  def login
    if request.get?
      flash.now[:info] = "Please login first."
      reset_current_user

    elsif user = User.authenticate(params[:ident], params[:password])
      flash[:info] = "User #{user.ident} logged in."
      set_current_user(user)

      reset_session_expires
      redirect_to(session[:jumpto] || '/')

    else
      flash.now[:danger] = "Invalid user/passwd."
      reset_current_user
    end
  end

  def logout
    user = User.current
    reset_current_user
    reset_session
    flash[:info] = "User #{user.ident} logged out."
    redirect_to "/"
  end
end
