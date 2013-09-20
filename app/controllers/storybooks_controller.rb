class StorybooksController < ApplicationController
  respond_to :html, :json

  before_filter :find_storybook, :except => [:create, :index]

  # Backbone.js extraneous parameter hack
  param_protected [:action, :controller, :format, :storybook], :only => :update

  def index
    set_signed_in_as_user
    respond_with(@storybooks = signed_in_as_user.storybooks.all)
  end

  def show
    respond_with @storybook
  end


  def create
    @storybook = signed_in_as_user.storybooks.new(params[:storybook])

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
    @storybook = signed_in_as_user.storybooks.find params[:id]
  end
end
