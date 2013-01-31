require 'spec_helper'

describe "Hotspot Widget", :js => true do
  before :each do
    # Create a storybook for a user
    @user = Factory(:user)
    @storybook = Factory.create(:storybook, :user => @user)

    login @user
    page.should have_content(@storybook.title)
    page.click_link(@storybook.title)
    page.find('.open-storybook').click
  end

  after :each do
    logout
  end

  context "sound effect" do
    before(:each) do
      s = Sound.new
      s.sound = File.open(Rails.root.join("spec/factories/sounds/voicemail_received.wav"))
      s.storybook_id = @storybook.id
      s.save!
    end

    xit "should be added from the toolbar and associated media selected" do
      page.find('.scene-list li:last-child span.scene-frame').click
      page.find('.touch-zones').click
      page.select('Play sound', :from => 'On touch')
      page.select('voicemail_received.wav', :from => 'Media to play')
      page.find('.btn.btn-primary.btn-submit').click
    end
  end
end
