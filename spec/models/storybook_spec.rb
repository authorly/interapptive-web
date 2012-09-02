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
    
    it { should belong_to(:user) }
    it { should have_many(:scenes) }
    it { should have_many(:images).through(:scenes) }
    it { should have_many(:sounds).through(:scenes) }
    it { should have_many(:videos).through(:scenes) }
    it { should have_many(:fonts).through(:scenes) }
    it { should have_one(:default_font) }
    
  end
  
  
end