module UserSessionsHelper
  attr_accessor :current_user
  def sign_in(user)
    puts "---- UserSessionsHelper::sign_in(user)"

   cookies['auth_token'] = user.auth_token
  #request.cookies[:auth_token] = user.auth_token


    current_user = user
  end

  def sign_out
    current_user = nil
    @current_user = nil
    cookies.delete(:auth_token)
  end

  def signed_in?
    !current_user.nil?
  end

  def current_user=(user)
    @current_user = user
  end

  def current_user
    @current_user ||= nil
  end

  def deny_access
    puts "---------------"
    puts "\n\n\n\n\n\n\n\n"
    puts "DENY"
    puts "\n\n\n\n\n\n\n\n"
    puts "---------------"
    redirect_to signin_path, :notice => "Please sign in to access this page."
  end


  def user_from_auth_token
    puts "find user from remember toke------>>>"
    auth_token = request.cookies[:auth_token]
    User.find_by_auth_token(auth_token) unless auth_token.nil?
  end

  def auth_token
    puts "remember token------>>>"
    request.cookies[:auth_token] || [nil, nil]
  end
end