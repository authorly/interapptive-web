class KissmetricsController < ApplicationController
  def create
    data = params[:km_event][:data] || {}

    if params[:km_event][:action] == 'record'
      KMTS.record(current_user.kissmetrics_identifier, params[:km_event][:name], data)

    elsif params[:km_event][:action] == 'set'
      KMTS.set(current_user.kissmetrics_identifier, :email => current_user.email)

    else
      logger.info "Unknown kissmetrics action called: #{params[:km_event][:action]}"
    end

    respond_to do |format|
      format.json { head :no_content }
    end
  end
end
