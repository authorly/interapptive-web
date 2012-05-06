class TouchZonesController < ApplicationController
  def index
    @touch_zones = TouchZone.limit(5)

    respond_to do |format|
      format.js { render 'scenes/touch_zones'}
    end
  end
end
