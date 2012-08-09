require 'spec_helper'

describe Scene do
  let!(:scene) { Factory(:scene) }

  it {Factory(:scene).should be_valid}
  it { should have_many(:keyframes)}


end