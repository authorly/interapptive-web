require 'spec_helper'

describe User do

  let!(:user) { Factory(:user) }

  describe "authentication" do
    it "should require a unique email" do
      Factory(:user, :email => 'taken@example.com')
      user = Factory.build(:user, :email => 'taken@example.com')
      user.should_not be_valid
    end

    it "should require a password and password_confirmation" do
      user = Factory.build(:user, :password => '')
      user.should_not be_valid

      user = Factory.build(:user, :password_confirmation => '')
      user.should_not be_valid

      user = Factory.build(:user, :password => "these", :password_confirmation => 'aredifferent')
      user.should_not be_valid
    end

    it 'should not require password for existing user unless password is changed' do
      user.update_attributes(:password => 'f', :password_confirmation => 'f').should_not be
      user.reload.update_attributes(:email => 'foo@bar.com').should be
    end

    it "should authenticate with a good password" do
      user.authenticate('supersecret').should == user
    end

    it "should not authenticate with a bad password" do
      user.authenticate('badpassword').should be_false
    end

    it "is invalid without email" do
      user = Factory.build(:user, :email => nil)
      user.should_not be_valid

      user = Factory.build(:user, :email => '')
      user.should_not be_valid
    end
  end

  describe 'confirm' do
    it 'should be true if already confirmed' do
      user.update_attribute(:confirmed, true)
      expect(user).to be_confirmed
    end

    it 'should confirm the user' do
      expect(user).not_to be_confirmed
      user.confirm
      expect(user).to be_confirmed
    end
  end

  context "a user (in general)" do
    it "has a valid factory" do
      user.should be_valid
    end

    # it "is invalid without password"

    it { should have_many(:storybooks) }

    # it do
      # pending
      # should have_many(:actions)
    # end
  end

  # context "developer user should" do
    # it "be invalid without username"
  # end

  context "password reset" do
    it "generates token" do
      user.send_password_reset.should
    end

    # it "saves password reset date"
    # it "sends password reset email"
    # it "fails if email doesn't exist"
  end

end
