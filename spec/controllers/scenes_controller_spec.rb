require 'spec_helper'

describe ScenesController do
  let!(:scene) { Factory(:scene) }
  let!(:user) { Factory(:user) }

  context 'creating a new scene' do

    it 'should add one scene' do
      # Make modular
      user = Factory.create(:user, :email => "email@gmail.com", :password => "password", :password_confirmation => "password")
      user.authenticate("password")

      lambda {
        post '/scenes.json', :scene
      }.should change(Scene, :page_number).by(1)
    end

    # context 'after creating, the new user' do
    #
    #   before do
    #     post '/api/users.json', :user => {:name => 'Charlie', :login => 'charlie'}
    #     @user = User.last
    #   end
    #
    #   subject { JSON.parse(response.body) }
    #
    #   it 'should have the correct name and login' do
    #     @user.name.should == 'Charlie'
    #     @user.login.should == 'charlie'
    #   end
    #
    #   it 'should be returned' do
    #     should == {'login' => 'charlie', 'name' => 'Charlie'}
    #   end
    #
    # end

  end

end