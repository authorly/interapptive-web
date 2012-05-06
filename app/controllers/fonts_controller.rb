class FontsController < ApplicationController
  def index
    @fonts = Font.limit(5)

    respond_to do |format|
      format.js
    end
  end
end
