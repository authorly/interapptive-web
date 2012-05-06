class SoundsController < ApplicationController
  def index
    @sounds = Sound.limit(5)

    respond_to do |format|
      format.js
    end
  end
end
