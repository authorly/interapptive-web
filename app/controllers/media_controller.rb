class MediaController < ApplicationController
  
  def index
    respond_to do |format|
      # Which content to render for modal
      case params[:from]
      when "videos"
        format.js { render(:videos) }
      when "sounds"
        format.js { render(:sounds) }
      when "images"
        format.js { render(:images) }
      when "fonts"
        format.js { render(:fonts) }
      when "actions"
        format.js { render(:actions) }
      when "scene_images"
        format.js { render(:scene_images) }
      when "scene_touch_zones"
        format.js { render(:scene_touch_zones) }
      when "preview"
        format.js { render(:preview) }
      end
    end
  end
  
end
