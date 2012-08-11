module Auth
  def with_user(role=:user_viewer)
    #if [:viewer,:editor,:administrator].include? role
    #  user = FactoryGirl.create(role)
    #  request.cookies[:auth_token] = user.auth_token
    #  return user
    #end
  end

end