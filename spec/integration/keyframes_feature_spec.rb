require "spec_helper"

describe "User's ability to add, edit and remove keyframes associated with scenes", :js => true do
  before :each do
    # Create a storybook for a user
    @user = Factory.create(:user)
    @storybook = @user.storybooks.first
    @storybook = Factory.create(:storybook, :user => @user) unless @storybook

    # Sign in
    login @user
    page.has_content?(@storybook.title)
    page.click_link(@storybook.title)
    page.find(".open-storybook").click
    page.click_link('Scene')
  end

  after :each do
    # Sign out
    logout
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
