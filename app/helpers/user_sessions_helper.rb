module UserSessionsHelper
  attr_accessor :current_user

  def current_user
    @current_user ||= User.find_by_auth_token!(cookies[:auth_token]) if cookies[:auth_token]
  end

  def signed_in?
    true if current_user
  end

  def authorize
    redirect_to sign_in_path, :alert => "Please sign in to continue." unless signed_in?
  end

  def sign_in(user)
    cookies.permanent[:auth_token] = user.auth_token
    self.current_user = user
  end
end
