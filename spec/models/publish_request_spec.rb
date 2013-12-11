require 'spec_helper'

describe PublishRequest do

  it { should belong_to(:storybook) }
  it { should have_many(:applications) }

end
