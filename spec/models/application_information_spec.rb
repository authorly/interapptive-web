require 'spec_helper'

describe ApplicationInformation do
  class ApplicationInformation
    # rspec uses `pretty_error_messages` that wants to access each
    # error key as a field of the object
    define_method "payee.name" do
      (self.payee||{})["name"]
    end
    define_method "payee.address" do
      (self.payee||{})["address"]
    end
  end

  it { Factory(:application_information).should be_valid }

  describe 'validation' do
    it { should validate_presence_of :available_from }
    it { should_not allow_value(1.day.ago).for(:available_from) }
    it { should allow_value(Date.today).for(:available_from) }
    it { should allow_value(1.day.from_now).for(:available_from) }

    it { should validate_presence_of :price_tier }
    it { should ensure_inclusion_of(:price_tier).in_array((1..15).map{|i| "tier_#{i}"})}

    it { should_not allow_value({}).for(:content_description) }
    it 'should allow a valid content description' do
      description = {
        'fantasy_violence' =>         'none',
        'realistic_violence' =>       'mild',
        'sexual_content' =>           'intense',
        'profanity' =>                'mild',
        'drugs' =>                    'none',
        'mature' =>                   'intense',
        'gambling' =>                 'none',
        'horror' =>                   'mild',
        'prolonged_violence' =>       'none',
        'graphical_sexual_content' => 'none',
      }
      should allow_value(description).for(:content_description)
    end

    it 'should not allow a content description with unexpected keys' do
      description = {
        'fantasy_violence' =>         'none',
        'realistic_violence' =>       'mild',
        'sexual_content' =>           'intense',
        'profanity' =>                'mild',
        'drugs' =>                    'none',
        'mature' =>                   'intense',
        'gambling' =>                 'none',
        'horror' =>                   'mild',
        'prolonged_violence' =>       'none',
        'graphical_sexual_content' => 'none',
        'x' =>                        'none',
      }
      should_not allow_value(description).for(:content_description)
    end

    it 'should not allow a content description with unexpected values' do
      description = {
        'fantasy_violence' =>         'x',
        'realistic_violence' =>       'mild',
        'sexual_content' =>           'intense',
        'profanity' =>                'mild',
        'drugs' =>                    'none',
        'mature' =>                   'intense',
        'gambling' =>                 'none',
        'horror' =>                   'mild',
        'prolonged_violence' =>       'none',
        'graphical_sexual_content' => 'none',
      }
      should_not allow_value(description).for(:content_description)
    end

    it { should validate_presence_of :description }
    it { should ensure_length_of(:description).
              is_at_most(4000) }

    it { should validate_presence_of :keywords }
    it { should ensure_length_of(:keywords).is_at_most(100) }

    it { should validate_presence_of :payee }
  end

  # TODO why it fails
  # it { should validate_presence_of :large_icon }

end
