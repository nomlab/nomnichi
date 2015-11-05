class GateController < ApplicationController
  skip_before_filter :authenticate

  def login
    return false if request.method_symbol == :get

    unless user = User.authenticate(params[:ident], params[:password])
      flash[:warning] = "Nickname and/or password are/is wrong."
      return false
    end

    set_current_user(user)
    redirect_to(session[:jumpto] || '/')
  end

  def omniauth
    auth = request.env["omniauth.auth"]

    unless auth.credentials.active_member?
      flash[:warning] = "Your account is unauthorized."
      render action: :login, status: 401
      return false
    end

    if user = User.find_by_provider_and_uid(auth["provider"], auth["uid"])
      flash[:info] = "#{user.ident} logged in."
      user.update_with_omniauth(auth)
      set_current_user(user)
      reset_session_expires
      redirect_to(session[:jumpto] || root_path)
      return true
    end

    if user = User.current
      flash[:info] = "Your account was assoiciated with GitHub."
      user.update_with_omniauth(auth)
      redirect_to controller: :users, action: :edit
      return true
    end

    set_omniauth_info(auth)
    flash[:info] = "Create nomnichi user."
    redirect_to controller: :users, action: :new
  end

  def logout
    flash[:info] = "User #{User.current.ident} logged out."
    reset_current_user

    reset_session
    redirect_to root_path
  end
end
