require 'spec_helper'

describe User do
  
  let!(:user) { Factory(:user) }
  
  describe "authentication" do
    it "should require a unique email" do
      Factory(:user, :email => 'taken@example.com')
      expect { Factory(:user, :email => 'taken@example.com') }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should require a password and password_confirmation" do
      expect { Factory(:user, :password => '') }.should raise_error(ActiveRecord::RecordInvalid)
      expect { Factory(:user, :password_confirmation => '') }.should raise_error(ActiveRecord::RecordInvalid)
      expect { Factory(:user, :password => 'these', :password_confirmation => 'aredifferent') }.should raise_error(ActiveRecord::RecordInvalid)
    end

    it "should authenticate with a good password" do
      user.authenticate('supersecret').should == user
    end

    it "should not authenticate with a bad password" do
      user.authenticate('badpassword').should be_false
    end
    
    it "is invalid without email" do 
      expect { Factory(:user, :email => nil) }.should raise_error(ActiveRecord::RecordInvalid)
    end

  end
  
  context "a user (in general)" do
    it "has a valid factory" do 
      user.should be_valid
    end
    
    it "is invalid without password"
    
    it { should have_many(:storybooks) }
    it { should have_many(:actions) }
  end
  
  context "developer user should" do 
    it "be invalid without username"
  end
  
  context "password reset" do
    it "generates token" do 
      user.send_password_reset.should 
    end
    it "saves password reset date"
    it "sends password reset email"
    it "fails if email doesn't exist"
  end
  
end
