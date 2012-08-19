require 'spec_helper'

describe StorybooksController do
  let!(:user) { Factory(:user) }
  let!(:storybook) { Factory(:storybook) }
  
  #TODO make a before call to sign in user and DRY up
  
  describe '#index' do
    it "populates an array of storybooks" do
      storybooks = []
      storybooks << Factory.create(:storybook, :user => user)
      test_sign_in(user)

      get :index, :format => :json
      response.should be_success
      response.body.should eq storybooks.to_json 
    end
  end

  describe 'GET #show' do
    it "requires user sign in"
    it "shows the right storybook" do
      #storybook = Factory.create(:storybook)
      get :show, :id => storybook['id'], :format => :json
      storybook.to_json.should eq response.body
    end
  end
    
  describe 'PUT #update' do
    context "with valid attributes" do
      it "updates the contact in the database" do 
        test_sign_in(user)
        storybook = Factory.create(:storybook, :user => user)
        put :update, :id => storybook['id'], :storybook => storybook.to_json, :format => :json
        response.should be_success
        response.body.should eq storybook.to_json
      end
    end
    
    context "with invalid attributes" do 
      it "does not update the storybook" do
        test_sign_in(user)
        storybook = Factory.create(:storybook, :user => user)
        put "/storybooks/#{storybook['id']}", :id => storybook['id'], :storybook => storybook.to_json, :format => :json
        response.should fail
        #last_response.body.should eq storybook.to_json
      end
      
      it "issues an error message" do
        
      end
    end 
  end
  
  describe 'DELETE #destroy' do
    it "deletes the storybook from the database" do
      
    end
  end
  
  describe "POST #create" do
    context "with valid attributes" do
      it "saves the new storybook" do
      
      end
    end
    context "with invalid attributes" do
      it "does not save the new storybook in the database" 
    end 
  end
  
  describe 'PUT #update' do
    context "with valid attributes" do
      it "updates the storybook"
    end
    context "with invalid attributes" do 
      it "does not update the contact" 
    end 
  end
  
  
  context 'guest user' do
    describe 'GET #show' do
      it "assigns the requested storybook" 
      it "renders the :show template"
    end
    describe 'GET #new' do 
      it "requires login"
    end
    describe "POST #create" do 
      it "requires login"
    end
    describe 'PUT #update' do 
      it "requires login"
    end
    describe 'DELETE #destroy' do 
      it "requires login"
    end
  end
  
  context 'admin user' do
    it "require admin login"
  end
  
end
