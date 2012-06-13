module SessionsHelper
  def authenticate
    redirect_to '/', :notice => 'please sign in to go to there.' if !signed_in?
  end

  def signed_in?
	session[:user_token] ? true : false
  end
end
