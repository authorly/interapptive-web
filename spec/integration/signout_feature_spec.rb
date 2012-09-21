require 'spec_helper'

describe "the signout process", :js => true do
  before :each do
    @user = Factory(:user)
    login @user
  end

  it "logs me out" do
    page.click_link "Exit"
    page.has_content? "Sign In"
  end
end
