require "spec_helper"

describe "User's ability to add, edit and remove keyframes associated with scenes", :js => true do
  before :each do
    # Create a storybook for a user
    @user = User.find_by_email('jack@daniles.com')
    @user = Factory.create(:user, :email => 'jack@daniles.com', :password => 'qwerty', :password_confirmation => 'qwerty') unless @user
    @storybook = @user.storybooks.first
    @storybook = Factory.create(:storybook, :user => @user) unless @storybook

    # Sign in
    page.visit sign_in_path
    page.fill_in "email", :with => "jack@daniles.com"
    page.fill_in "password", :with => "qwerty"
    page.click_button "Sign In"
    page.has_content?(@storybook.title)
    page.click_link(@storybook.title)
    page.find(".open-storybook").click
    page.click_link('Scene')
  end

  after :each do
    # Sign out
    page.visit root_path
    page.find('a[@href="/users/sign_out"]').click
  end

  it "should add a keyframe to the end of the list" do
    page.click_link('Keyframe')
    page.within('ul.keyframe-list') do
      page.find('li.active')
    end
  end

  it 'should remove a keyframe' do
    pending
  end
end
