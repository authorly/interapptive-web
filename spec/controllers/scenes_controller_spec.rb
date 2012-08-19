require 'spec_helper'

describe ScenesController do
  let!(:scene) { Factory(:scene) }
  let!(:user) { Factory(:user) }

  context 'creating a new scene' do
    it 'should add one scene' do
      user = Factory.create(:user, :email => "email@gmail.com", :password => "password", :password_confirmation => "password")
      user.authenticate("password")

      lambda {
        post '/scenes.json', :scene
      }.should change(Scene, :page_number).by(1)
    end
  end
end