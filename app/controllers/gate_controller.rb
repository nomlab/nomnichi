class GateController < ApplicationController
  skip_before_filter :authenticate

  def index
  end

  def login
    # Associate with provider account
    auth = request.env["omniauth.auth"]
    if auth && User.current
      User.current.update_with_omniauth(auth)
      flash[:info] = "Nomnichi account is associated with #{auth["provider"]}"
      redirect_to root_path + "settings"
      return false
    end

    # Omni Auth
    if auth
      unless auth.credentials.active_member?
        render text: "Unauthorized", status: 401
        return false
      end

      user = User.find_by_provider_and_uid(auth["provider"], auth["uid"]) ||
             User.create_with_omniauth(auth)

    # BASIC authentication
    else
      user = User.authenticate(params[:ident], params[:password])
    end

    if user
      flash[:info] = "User #{user.ident} logged in."
      set_current_user(user)

      reset_session_expires
      redirect_to(session[:jumpto] || root_path)

    else
      flash.now[:danger] = "Invalid user/passwd."
      reset_current_user
    end
  end

  def logout
    user = User.current
    reset_current_user
    flash[:info] = "User #{user.ident} logged out."
    reset_session
    redirect_to root_path
  end
end
