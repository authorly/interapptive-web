require 'spec_helper'

describe StorybooksController, :type => :api do
  render_views

  let!(:storybook) { Factory(:storybook) }
  let!(:user) { Factory(:user) }
  let!(:token) { user.auth_token }

  before do
    request.cookies[:auth_token] = user.auth_token

    puts "\n--------------"
    puts "\n--------------"
    puts "\n------2--------"
    puts request.cookies['auth_token']
    puts response.cookies['auth_token']
    puts cookies['auth_token']
    puts "\n--------------"
    puts "\n--------------"
    puts "\n--------------"
    puts "\n--------------"
  end

  let(:url) { "/storybooks.json" }

  context "authenticated user" do
    it "is authenticated" do
      with_user(user)
      get "/"
      puts last_response.to_yaml
      last_response.status.should == 200


      # get '/storybooks.json'
      # #last_response.status.should == 302
      # puts last_response.to_yaml
      # redirect_to(root_path)
      # expect { redirect_to(root_path) }

      #last_response.should redirect_to(root_path)
    end
  end
end

#describe StorybooksController do
#  render_views
#
#  let!(:storybook) { Factory(:storybook) }
#  let!(:user) { Factory(:user)             }
#  let(:token) { user.auth_token }
#
#  let(:url) { "/storybooks.json" }
#
#  before do
#    Factory(:storybook, :user_id => user)
#  end
#
#  context "successful requests" do
#    it "can get a list of storybooks" do
#
#    end
#  end
#
#  # context "unsuccessful requests" do
#  #   it "doesn't pass through a token" do
#  #     get url
#  #     last_response.status.should eql(401)
#  #     last_response.body.should eql("Token is invalid.")
#  #   end
#  #
#  #   it "cannot access a project that they don't have permission to" do
#  #     user.permissions.delete_all
#  #     get url, :token => token
#  #     last_response.status.should eql(404)
#  #   end
#  # end
#
#  # context "authenticated user" do
#  #   it "is authenticated" do
#  #     user.authenticate("supersecret").should == user
#  #   end
#  # end
#
#  # describe 'GET #index' do
#  #   it "populates an array of storybooks" do
#  #     user.authenticate "supersecret"
#  #     #user.should be signed in?
#  #     storybook = Factory.create(:storybook)
#  #     get :index, :format => :json
#  #     #assigns(:storybooks).should eq [storybook]
#  #     response.body.should have_content storybook.to_json
#  #     #puts "story book #{storybook}"
#  #     #response.body.should  have_conten storybook
#  #   end
#  #
#  #   it "renders the :index view" do
#  #     user.authenticate "password"
#  #     get :index, :format => :json
#  #     response.should render_template :index
#  #   end
#  # end
#
#  # describe 'GET #show' do
#  #   it "assigns the requested storybook to @storybook" do
#  #     storybook = Factory.create(:storybook).attributes
#  #     get :show, id: storybook
#  #     assigns(:storybook).should eq storybook
#  #   end
#  #   it "renders the :show json" do
#  #     storybook = Factory.create(:storybook).attributes
#  #     get :show, id: storybook, :format => :json
#  #     puts "show response #{response.body}"
#  #     response.body.should eq storybook
#  #   end
#  # end
#end