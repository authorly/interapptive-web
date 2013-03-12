require 'spec_helper'

describe Storybook do

  let!(:storybook) { Factory(:storybook) }

  describe "storybook creation" do

    it "has a valid factory"
    specify { should be_an_instance_of(Storybook) }

    it "increments storybook count" do
      expect { Storybook.create :title => "New Storybook" }.to change { Storybook.count }.by(1)
    end

    it "can be created"
    it "creates a storybook"
    it "requires a title"
    it "requires an author"
    it "requires a description"
    it "requires a price"
    it "requires a device"
    it "requires tablet or phone"

    it "requires unique title" do
      pending
      expect { Factory(:storybook) }.to validate_uniqueness_of(:title)
    end

    it 'should create a default scene and a main menu scene in the storybook' do
      story = Factory(:storybook)
      story.scenes.count.should == 2

      story.scenes.first.is_main_menu.should == true
      story.scenes.first.position.should == nil

      story.scenes.last.is_main_menu.should == false
      story.scenes.last.position.should == 0
    end
  end

  describe '#owned_by?' do
    it 'should be owned by its user' do
      storybook.owned_by?(storybook.user).should be_true
    end

    it 'should not be owned by somone else' do
      user = Factory(:user)
      storybook.owned_by?(user).should be_false
    end
  end
end
