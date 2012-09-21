module Auth
  def with_user(role=:user_viewer)

    #if [:viewer,:editor,:administrator].include? role
    #  user = FactoryGirl.create(role)
    #  request.cookies[:auth_token] = user.auth_token
    #  return user
    #end
  end

end

def login(user)
  page.visit sign_in_path
  page.fill_in "email", :with => user.email
  page.fill_in "password", :with => user.password
  page.click_button "Sign In"
end

def logout
  page.visit root_path
  page.find('a[@href="/users/sign_out"]').click
end
