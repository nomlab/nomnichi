class UsersController < ApplicationController
  before_action :set_user, only: [:show, :update, :destroy, :change_password]
  before_filter :authenticate

  # GET /users
  # GET /users.json
  def index
    @users = User.all
  end

  # GET /users/1
  # GET /users/1.json
  def show
  end

  # GET /users/new
  def new
    @user = User.new
  end

  # GET /users/1/edit
  def edit
    @user = User.current
  end

  # POST /users
  # POST /users.json
  def create
    @user = User.new(user_params)

    respond_to do |format|
      if @user.save
        format.html { redirect_to @user, notice: 'User was successfully created.' }
        format.json { render :show, status: :created, location: @user }
      else
        format.html { render :new }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # PATCH/PUT /users/1
  # PATCH/PUT /users/1.json
  def update
    respond_to do |format|
      if @user.update(user_params)
        format.html {
          flash[:info] = 'Successfully updated.'
          render :edit
        }
        format.json { render :show, status: :ok, location: @user }
      else
        format.html {
          flash[:danger] = 'Updating was failed.'
          render :edit
        }
        format.json { render json: @user.errors, status: :unprocessable_entity }
      end
    end
  end

  # DELETE /users/1
  # DELETE /users/1.json
  def destroy
    @user.destroy
    respond_to do |format|
      format.html { redirect_to users_url, notice: 'User was successfully destroyed.' }
      format.json { head :no_content }
    end
  end

  # POST /users/1/change_password
  def change_password
    unless User.authenticate(@user.ident, params[:old_password]) == User.current
      flash[:danger] = 'Old password is wrong.'
      redirect_to root_path + "settings"
      return false
    end

    unless params[:new_password] == params[:password_for_confirming]
      flash[:danger] = 'Password does not match the confirmation'
      redirect_to root_path + "settings"
      return false
    end

    unencrypted_password = params[:new_password]
    salt = User.generate_salt
    encrypted_password = User.encrypted_password(unencrypted_password, salt)

    if @user.update(password: encrypted_password, salt: salt)
      flash[:info] = 'Successfully updated.'
      redirect_to root_path + "settings"
    else
      flash[:danger] = 'Updating was failed.'
      render root_path + "settings"
    end
  end

  private
    # Use callbacks to share common setup or constraints between actions.
    def set_user
      @user = User.find(params[:id])
    end

    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
      params.require(:user).permit(:ident, :password, :salt)
    end
end
