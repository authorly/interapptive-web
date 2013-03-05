require 'spec_helper'

describe "Text Widget", :js => true do
  before :each do
    @user = Factory(:user)
    @storybook = Factory.create(:storybook, :user => @user)

    login @user
    page.should have_content(@storybook.title)
    page.click_link(@storybook.title)
    page.find(".open-storybook").click
    page.click_link('Scene')
  end

  after :each do
    logout
  end

  context "adding to a scene" do
    xit "should add text to the DOM" do
      page.find('.edit-text').click
      page.should have_content('Enter some text...')
    end
  end

  context "toolbar" do
    before(:each) do
      f = Font.new
      f.font = File.open(Rails.root.join("spec/factories/fonts/grunge.ttf"))
      f.storybook_id = @storybook.id
      f.save!
    end

    xit "should have uploaded fonts" do
      page.visit('/')
      page.click_link(@storybook.title)
      page.find(".open-storybook").click
      page.click_link('Scene')
      page.find('.edit-text').click
      page.has_select?('#font_face', 'Grunge Regular')
    end

    xit "should select an uploaded fonts to apply" do
      page.visit('/')
      page.click_link(@storybook.title)
      page.find(".open-storybook").click
      page.click_link('Scene')
      page.find('.add-text').click
      page.select('Grunge Regular', :from => 'font_face')
    end

    xit "should allow deleting" do
      page.find('.add-text').click
      page.find('.text_widget').click
      page.find('.delete').click
    end
  end
end
