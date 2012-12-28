require 'spec_helper'

describe "Sprite Widget", :js => true do
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
    before(:each) do
      @image = Image.new
      @image.image = File.open(Rails.root.join("spec/factories/images/350x350.png"))
      @image.storybook_id = @storybook.id
      @image.save!
    end

    it "should add a sprite from existing images" do
      page.find('.add-image').click
      page.find('.image-row').click
      page.find('.btn').click
    end

    it "should create an element in the sprite list" do
      page.has_selector?('li', :text => @image.image.filename, :visible => true)
    end

    it "should be removed from list when deleted" do
      page.find('.add-image').click
      page.find('.image-row').click
      page.find('.btn').click
      page.execute_script("$('.sprites li:first-child .delete').show()")
      page.find('.delete').click
    end
  end
end
