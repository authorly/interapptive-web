require 'spec_helper'

describe "the signup process", :js => true do
  before :each do
    @user = Factory(:user, :email => 'jack@daniles.com', :password => 'qwerty', :password_confirmation => 'qwerty')
  end

  it "logs me in with correct password" do
    page.visit sign_in_path
    page.fill_in "email", :with => "jack@daniles.com"
    page.fill_in "password", :with => "qwerty"
    page.click_button "Sign In"

    page.has_content?("New or Open Storybook App..")
  end
end
