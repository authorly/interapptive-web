require 'spec_helper'

describe Settings do
  let!(:settings) { Factory(:settings) }
  
  describe "has a valid factory" do
    specify { should be_an_instance_of(Settings) }
  end
  
  it "can be created"
  it "validates scene id"
  it "validates a storybook id"
  it "validates a font id"
  it "validates a font size"
  
end