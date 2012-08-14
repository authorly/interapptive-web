require 'spec_helper'

describe StorybookSettings do 
  let!(:storybook_settings) { Factory(:storybook_settings) }
  
  describe "has a valid factory" do
    specify { should be_an_instance_of(StorybookSettings) }
  end
  
  it "can be created"
  it "validates scene id"
  it "validates a storybook id"
  it "validates a font id"
  it "validates a font size"
end