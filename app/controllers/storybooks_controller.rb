class StorybooksController < ApplicationController
  before_filter :find_storybook, :except => [:create, :index]

  # Backbone.js extraneous parameter hack
  param_protected [:action, :controller, :format, :storybook], :only => :update

  def index
    @storybooks = current_user.storybooks.all
    respond_to do |format|
      format.json { render :json => @storybooks }
    end
  end
  
  def show
    respond_to do |format|
      format.json { render :json => @storybook }
    end
  end


  def create
    @storybook = current_user.storybooks.new(params[:storybook])

    respond_to do |format|
      if @storybook.save
        format.json { render :json => @storybook, :status => :created }
      else
        format.json { render :json => @storybook.errors, :status => :unprocessable_entity }
      end
    end
  end


  def update
    # Remove Backbone hack parameter from attributes
    # params[:_method] = params.delete(:_method) if params.has_key? :_method

    respond_to do |format|
      if @storybook.update_attributes(params)
        format.json { render :json => @storybook }
      else
        format.json { render :json => @storybook.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @storybook.destroy

    respond_to do |format|
      format.html { redirect_to root_path }
      format.json { head :ok }
    end
  end

  private

  def find_storybook
    @storybook = current_user.storybooks.find params[:id]
  end
end
