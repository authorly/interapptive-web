require 'spec_helper'

describe "User's ability to upload and manage various assets", :js => true do
  before :each do
    # Create a storybook for a user
    @user = Factory(:user)
    @storybook = Factory.create(:storybook, :user => @user)

    # Sign in
    login @user
    page.should have_content(@storybook.title)
    page.click_link(@storybook.title)
    page.find(".open-storybook").click
    page.click_link('Scene')
  end

  after :each do
    # Sign out
    logout
  end

  context "fonts" do
    before(:each) do
      page.click_link("Fonts")
      page.should have_content("Font Library")
      page.attach_file('font[files][]', Rails.root.join('spec/factories/fonts/font.ttf'))
    end

    it "should select multiple local fonts to upload" do
      page.attach_file('font[files][]', Rails.root.join('spec/factories/fonts/cinema.ttf'))
      page.find('.start').click
      slow_down
      page.should have_content('font.ttf')
      page.should have_content('cinema.ttf')
    end

    it "should delete a local font before uploading" do
      page.should have_content('font.ttf')
      page.find('.cancel').click
      page.should have_content('font.ttf')
    end

    it "should upload selected fonts" do
      page.attach_file('font[files][]', Rails.root.join('spec/factories/fonts/cinema.ttf'))
      slow_down
      page.within('table.table-striped') do
        page.find('td.start > button').click
      end
      slow_down
      page.within('table.table-striped') do
        page.find('td.delete')
      end
    end

    it "should delete an uploaded font" do
      page.find('.start').click
      slow_down
      page.within('table.table-striped') do
        page.find('td.delete > button').click
      end
      slow_down
      page.should_not have_content('font.ttf')
    end
  end

  context "images" do
    before(:each) do
      page.click_link("Images")
      page.should have_content("Image Library")
      page.attach_file('image[files][]', Rails.root.join('spec/factories/images/350x350.png'))
    end

    it "should select a single local image to upload" do
      page.find('.start').click
      slow_down
      page.within('table.table-striped') do
        page.find('td.delete')
        page.should have_content('350x350.png')
      end
    end

    it "should upload the selected image" do
      page.attach_file('image[files][]', Rails.root.join('spec/factories/images/kitty_316x237.jpg'))
      page.within('table.table-striped') do
        page.find('td.start > button').click
      end
      slow_down
      page.within('table.table-striped') do
        page.find('td.delete')
      end
    end

    it "should delete the uploaded image" do
      page.find('.start').click
      slow_down
      page.within('table.table-striped') do
        page.find('td.delete > button').click
      end
      slow_down
      page.should_not have_content('350x350.png')
    end
  end

  context "sounds" do
    before(:each) do
      page.click_link("Sounds")
      page.should have_content("Sound Library")
      page.attach_file('sound[files][]', Rails.root.join('spec/factories/sounds/voicemail_received.wav'))
    end

    it "should select multiple local sounds to upload" do
      page.attach_file('sound[files][]', Rails.root.join('spec/factories/sounds/voicemail_received_again.wav'))
      page.find('.start').click
      slow_down
      page.should have_content('voicemail_received.wav')
      page.should have_content('voicemail_received_again.wav')
    end

    it "should delete a local sound before uploading" do
      page.should have_content('voicemail_received.wav')
      page.find('.cancel').click
      page.should_not have_content('voicemail_received.wav')
    end

    it "should upload selected sounds" do
      page.attach_file('sound[files][]', Rails.root.join('spec/factories/sounds/voicemail_received_again.wav'))
      page.within('table.table-striped') do
        page.find('td.start > button').click
      end
      slow_down
      page.within('table.table-striped') do
        page.find('td.delete')
      end
    end

    it "should delete an uploaded sound" do
      page.find('.start').click
      slow_down
      page.within('table.table-striped') do
        page.find('td.delete > button').click
      end
      slow_down
      page.should_not have_content('voicemail_received.wav')
    end
  end

  context "videos" do
    before(:each) do
      page.click_link("Videos")
      page.should have_content("Video Library")
      page.attach_file('video[files][]', Rails.root.join('spec/factories/videos/null_video.flv'))

      zencoder_response = Object.new
      def zencoder_response.body; { :zencoder => 'response' }; end
      Zencoder::Job.stub(:create).and_return(zencoder_response)
    end

    it "should select multiple local videos to upload" do
      page.attach_file('video[files][]', Rails.root.join('spec/factories/videos/null_video_again.flv'))
      page.find('.start').click
      slow_down
      page.should have_content('null_video.flv')
      page.should have_content('null_video_again.flv')
    end

    it "should delete a local video before uploading" do
      page.should have_content('null_video.flv')
      page.find('.cancel').click
      page.should_not have_content('null_video.flv')
    end

    it "should upload selected videos" do
      page.attach_file('video[files][]', Rails.root.join('spec/factories/videos/null_video_again.flv'))
      page.within('table.table-striped') do
        page.find('td.start > button').click
      end
      slow_down
      page.should have_content('Your video is being transcoded. Please check later.')
    end

    it "should delete an uploaded video" do
      pending
      page.find('.start').click
      page.within('table.table-striped') do
        page.find('td.delete > button').click
      end
      slow_down
      page.should have_content('Your video is being transcoded. Please check later.')
    end
  end
end
