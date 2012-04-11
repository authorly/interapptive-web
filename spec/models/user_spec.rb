require 'spec_helper'

describe User do
  describe "authentication" do
    it "should require a unique email" do
      Factory(:user, :email => 'taken@example.com')
      lambda { Factory(:user, :email => 'taken@example.com') }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should require a password and password_confirmation" do
      lambda { Factory(:user, :password => '') }.should raise_error(ActiveRecord::RecordInvalid)
      lambda { Factory(:user, :password_confirmation => '') }.should raise_error(ActiveRecord::RecordInvalid)

      lambda { Factory(:user, :password => 'these', :password_confirmation => 'aredifferent') }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should authenticate with a good password" do
      user = Factory(:user)
      user.authenticate('supersecret').should == user
    end

    it "should not authenticate with a bad password" do
      user = Factory(:user)
      user.authenticate('badpassword').should be_false
    end
  end
end
