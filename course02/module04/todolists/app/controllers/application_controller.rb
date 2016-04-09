# Comment
class ApplicationController < ActionController::Base
  # Prevent CSRF attacks by raising an exception.
  # For APIs, you may want to use :null_session instead.
  protect_from_forgery with: :exception
  helper_method :logged_in?, :current_user, :ensure_login
  before_action :ensure_login

  protected

  def ensure_login
    redirect_to login_path unless current_user
  end

  def logged_in?
    !current_user.nil?
  end

  def current_user
    User.find(session['user.id']) unless session['user.id'].nil?
  end

end
