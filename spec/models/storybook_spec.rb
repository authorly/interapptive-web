require 'spec_helper'

describe Storybook do

  let!(:storybook) { Factory(:storybook) }
  it { storybook.should be_valid }

  it { should have_one(:publish_request) }

  describe 'validation' do

    it { should validate_presence_of :user }

    describe 'maximum allowed storybooks' do
      let!(:user) { Factory(:user, allowed_storybooks_count: 1) }

      it 'should allow creating a storybook' do
        s = Factory.build(:storybook, user: user)
        s.save.should == true
      end

      it 'should not allow creating a second storybook' do
        Factory(:storybook, user: user)
        s = Factory.build(:storybook, user: user)
        s.save.should == false
      end
    end

    describe 'unique title per user' do
      it 'allows creating a storybook with same user but different title' do
        s = Factory.build(:storybook, user: storybook.user)
        s.save
        s.should have(:no).error_on(:title)
      end

      it 'allows creating a storybook with a different user and the same title' do
        s = Factory.build(:storybook, title: storybook.title, user: Factory(:user))
        s.save
        s.should have(:no).error_on(:title)
      end

      it 'does not allow creating a storybook with same user and same title' do
        s = Factory.build(:storybook, user: storybook.user, title: storybook.title)
        s.save
        s.should have(1).error_on(:title)
      end
    end

  end

  describe "storybook creation" do

    it 'should add a home button widget' do
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
      storybook.scenes.count.should == 2

      storybook.scenes.where(is_main_menu: true, position: nil).count.should == 1
      storybook.scenes.where(is_main_menu: false, position: 0).count.should == 1
    end

    it 'should have the default settings' do
      storybook.pageFlipTransitionDuration.should == 0.6
      storybook.paragraphTextFadeDuration.should == 0.4
      storybook.autoplayPageTurnDelay.should == 0.2
      storybook.autoplayKeyframeDelay.should == 0.1
    end
  end

  describe '#owned_by?' do
    it 'should be owned by its user' do
      storybook.owned_by?(storybook.user).should be_true
    end

    it 'should not be owned by someone else' do
      user = Factory(:user)
      storybook.owned_by?(user).should be_false
    end
  end

  describe '#create_or_update_subscription_publish_request' do
    context 'when publish request is missing' do
      it 'should create a new request' do
        expect(storybook.subscription_publish_request).to be_blank
        storybook.create_or_update_subscription_publish_request
        storybook.reload
        expect(storybook.subscription_publish_request).to be_present
        expect(storybook.subscription_publish_request.status).to eql(SubscriptionPublishRequest::STATUSES[:review_required])
      end
    end

    context 'when publish request is present' do
      it 'should update existing request for review-required' do
        storybook.create_or_update_subscription_publish_request
        expect(storybook.subscription_publish_request).to be_present
        storybook.subscription_publish_request.update_attribute(:status, SubscriptionPublishRequest::STATUSES[:published])
        spr = storybook.subscription_publish_request
        storybook.create_or_update_subscription_publish_request
        expect(storybook.subscription_publish_request).to eql(spr)
        storybook.reload
        expect(storybook.subscription_publish_request.status).to eql(SubscriptionPublishRequest::STATUSES[:review_required])
      end
    end
  end

  describe '#requires_subscription_publication_review?' do
    context 'publish request is missing' do
      it 'should be false' do
        expect(storybook.subscription_publish_request).to be_blank
        expect(storybook.requires_subscription_publication_review?).not_to be
      end
    end

    context 'publish request status is review-required' do
      it 'should be true' do
        storybook.create_or_update_subscription_publish_request
        expect(storybook.subscription_publish_request.status).to eql(SubscriptionPublishRequest::STATUSES[:review_required])
        expect(storybook.requires_subscription_publication_review?).to be
      end
    end

    context 'publish request status is not review required' do
      it 'should be false' do
        storybook.create_or_update_subscription_publish_request
        storybook.subscription_publish_request.update_attribute(:status, SubscriptionPublishRequest::STATUSES[:published])
        expect(storybook.requires_subscription_publication_review?).not_to be
      end
    end
  end

  describe '#enqueue_for_subscription_publication' do
    it 'readies storybook for publication' do
      user = Factory(:user)
      storybook.create_or_update_subscription_publish_request
      Resque.should_receive(:enqueue).with(SubscriptionPublicationQueue, storybook.id, {}, user.email)
      storybook.enqueue_for_subscription_publication({}, user)
      expect(storybook.subscription_publish_request.status).to eql(SubscriptionPublishRequest::STATUSES[:ready_to_publish])
    end
  end
end
