class KmetricsController < ApplicationController
  def create
    data = params[:km_event][:data] || {}

    if params[:km_event][:action] == 'record'
      KMTS.record(current_user.email, params[:km_event][:name], data)

    else
      logger.info "Unknown kissmetrics action called: #{params[:km_event][:action]}"
    end

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
