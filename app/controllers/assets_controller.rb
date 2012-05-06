class AssetsController < ApplicationController
  
  def index
    respond_to do |format|
      # Which content to render for modal
      case params[:from]
      when "fonts"
        format.js { render(:fonts) }
      when "actions"
        format.js { render(:actions) }
      when "scene_touch_zones"
        format.js { render(:scene_touch_zones) }
      when "preview"
        format.js { render(:preview) }
      end
    end
  end
  
end
