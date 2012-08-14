require 'spec_helper'

describe StorybooksController do
  let!(:user) { Factory(:user) }
  
  describe '#index' do
    it "populates an array of storybooks" do
      storybook = Factory.create(:storybook, :user => user)
      test_sign_in(user)

      get '/storybooks.json'
      response.should be_success
      p last_response.to_yaml
      p response.body
    end
  end
  
  describe 'GET #show' do
    it "assigns the requested storybook to @storybook" do
      storybook = Factory.create(:storybook).attributes
      get :show, id: storybook 
      assigns(:storybook).should eq storybook
    end

    it "renders the :show json" do 
      storybook = Factory.create(:storybook).attributes
      get :show, id: storybook, :format => :json
      puts "show response #{response.body}"
      response.body.should eq storybook
    end
  end
end
