require 'spec_helper'

describe "the signup process", :js => true do
  before :each do
    @user = Factory(:user)
  end

  it "logs me in with correct password" do
    login @user
    page.has_content?("New or Open Storybook App..")
  end
end
