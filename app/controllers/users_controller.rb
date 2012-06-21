class UsersController < ApplicationController
  before_filter :authenticate
  before_filter :authenticate_admin, :except => ['password','update']
  before_filter :user_is_params_id, :only => ['edit', 'password', 'update', 'destroy']

  def password
    if params[:id].to_i == current_user.id
      @request_url = request.referer
      session[:redirect_back] = request.referer
    else
      flash[:notice] = "you're an idiot"
      redirect_to '/notifications/new'
    end
  end
  
  def index
    @users = User.all
  end

  def new
    @user = User.new
  end

  def create
    @user = User.new(params[:user])
    if @user.save
      redirect_to users_path, :notice => "#{@user.name} created"
    else
      flash[:notice] = 'Something went wrong. Try again'
      redirect_to request.referer
    end
  end

  def update
    if changing_password?
      change_password
    elsif @user.update_attributes(params[:user])
      redirect_to users_path, :notice => "#{@user.name} updated"
    else
      redirect_to edit_user_path @user, :notice => "Something went wrong. Try again."
    end
  end

  def destroy
    @user.destroy
    redirect_to users_path
  end

private

  def user_is_params_id
    @user = User.find(params[:id])
  end

  def changing_password?
    @old_password = params[:user][:old_password]
  end

  def change_password
    if @user.authenticate(@old_password) && @user.update_attributes(params[:user])
      flash[:notice] = 'new password saved!'
      redirect_to session[:redirect_back]
    elsif @user.authenticate(@old_password) 
      flash[:notice] = "Password confirmation doesn't match"
      redirect_to request.referer
    else
      flash[:notice] = "Old password didn't match existing one"
      redirect_to request.referer
    end
  end
end
