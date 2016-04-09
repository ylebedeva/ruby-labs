#
class SessionsController < ApplicationController
  skip_before_action :ensure_login, only: [:new, :create]

  def create
    @user = User.where(username: params[:user][:username]).first
    if @user.nil?
      redirect_to login_path, alert: 'User was not found.'
    elsif @user.authenticate(params[:user][:password])
      session['user.id'] = @user.id
      redirect_to root_path, notice: 'Logged in successfully'
    else
      redirect_to login_path, alert: 'Login was unsuccessful.'
    end
  end

  def destroy
    session.delete 'user.id'
    redirect_to root_path, notice: 'Logout was successful.'
  end
end
