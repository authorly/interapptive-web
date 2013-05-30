require 'spec_helper'

describe Storybook do

  let!(:storybook) { Factory(:storybook) }
  it { Factory(:scene).should be_valid }

  describe "storybook creation" do

    specify { should be_an_instance_of(Storybook) }

    it "increments storybook count" do
      expect { Storybook.create :title => "New Storybook" }.to change { Storybook.count }.by(1)
    end

    # it "can be created"
    # it "creates a storybook"
    # it "requires a title"
    # it "requires an author"
    # it "requires a description"
    # it "requires a price"
    # it "requires a device"
    # it "requires tablet or phone"

    # it "requires unique title" do
      # pending
      # expect { Factory(:storybook) }.to validate_uniqueness_of(:title)
    # end

    it 'should add a home button widget' do
      storybook = Factory.create(:storybook)

      storybook.widgets.should be
      storybook.widgets.count.should == 1

      home =  storybook.widgets[0]
      home[:id].should == 1
      home[:type].should == 'ButtonWidget'
      home[:name].should == 'home'
      home[:z_order].should == 4010
      home[:scale].should == 1
      home[:position].should == {y: 400, x: 200}
    end

    it 'should create a default scene and a main menu scene in the storybook' do
      story = Factory(:storybook)
      story.scenes.count.should == 2

      story.scenes.where(is_main_menu: true, position: nil).count.should == 1
      story.scenes.where(is_main_menu: false, position: 0).count.should == 1
    end

    it 'has the default settings' do
      story = Factory(:storybook)
      story.pageFlipTransitionDuration.should == 0.6
      story.paragraphTextFadeDuration.should == 0.4
      story.autoplayPageTurnDelay.should == 0.2
      story.autoplayParagraphDelay.should == 0.1
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
