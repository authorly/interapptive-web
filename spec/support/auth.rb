module Auth
  def with_user(user)
    puts "\n--------------"
    puts "AUTH YO"
    puts "--------------\n"
    cookies['auth_token'] = user.auth_token
    puts "\n--------------"
    puts "\n--------------"
    puts "\n------1--------"
    puts cookies['auth_token']
    puts "\n--------------"
    puts "\n--------------"
    puts "\n--------------"
    puts "\n--------------"
    # @request.cookies[:auth_token] = user.auth_token
    # cookies[:auth_token] = user.auth_token
  end
end