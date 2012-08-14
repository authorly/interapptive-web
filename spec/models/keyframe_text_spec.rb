require 'spec_helper'

describe KeyframeText do
  let!(:keyframe_text) { Factory(:keyframe_text) }
  
  context "on creation" do
    it "sets default text to (something)"
    it "sets default font size to (some size)"
    it "sets default x_coord to (some x coord)"
    it "sets default y_coord to (some y coord)"
    it "sets default font face to (some font face)"
    it "sets default font size to (some font size)"
    it "sets default font color to (some font color)"
    
    it "is invalid without text"
    it "is invalid without font size"
    it "is invalid without a x_coord"
    it "is invalid without a y_coord"
    it "is invalid without a font face"
    it "is invalid without a font size"
    it "is invalid without a font color"
  end
end