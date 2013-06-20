require 'spec_helper'
require 'carrierwave/test/matchers'

describe SoundUploader do
  include CarrierWave::Test::Matchers

  before do
    SoundUploader.enable_processing = true
    @sound = Factory :sound, sound: File.open(Rails.root.join('spec', 'support', 'voiceovers', 'page-1-paragraph-1.wav'))
  end

  after do
    SoundUploader.enable_processing = false
    @sound.sound.remove!
  end

  it "should store the duration" do
    @sound.meta_info[:duration].should == 6.72
  end
end
