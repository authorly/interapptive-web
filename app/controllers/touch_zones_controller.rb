class TouchZonesController < ApplicationController
  before_filter :authorize
  before_filter :fetch_keyframe
  before_filter :fetch_touch_zone, :except => [:index, :create, :update]

  def index
    @touch_zones = @keyframe.touch_zones

    respond_to do |format|
      format.js { render :json => @touch_zones }
    end
  end

  def show
    respond_to do |format|
      format.json { render :json => @touch_zone }
    end
  end

  def create
    @touch_zone = @keyframe.touch_zones.new params[:touch_zone]

    respond_to do |format|
      if @touch_zone.save
        format.json { render :json => @touch_zone, :status => :created }
      else
        format.json { render :json => @keyframe.errors, :status => :unprocessable_entity }
      end
    end
  end

  def edit
    respond_to do |format|
      format.json { render :json => @touch_zone }
    end
  end

  def update
    @touch_zone = @keyframe.touch_zones.find params[:id]
    respond_to do |format|
      if @touch_zone.update_attributes params[:touch_zone]
        format.json { render :json => @touch_zone, :status => :updated }
      else
        format.json { render :json => @touch_zone.errors, :status => :unprocessable_entity }
      end
    end
  end

  def destroy
    @touch_zone.destroy

    respond_to do |format|
      format.json { render :json => {:status => :ok } }
    end
  end

  private
  def fetch_keyframe
    @keyframe = KeyFrame.find params[:keyframe_id]
  end

  def fetch_touch_zone
    @touch_zone = @keyframe.touch_zones.find params[:id]
  end
end
