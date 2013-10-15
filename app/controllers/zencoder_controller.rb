class ZencoderController < ApplicationController
  skip_before_filter :verify_authenticity_token, :authorize, :http_authorize

  def create
    pass_through = params[:job].try(:[], :pass_through)
    if pass_through.present?
      model_name, model_id = pass_through.split('_')
      model = case model_name
              when 'Sound'
                Sound.find_by_id(model_id)
              when 'Video'
                Video.find_by_id(model_id)
              else
                nil
              end
      if model.present?
        model.store_transcoding_result(params[:zencoder])
      end
    end
    render :nothing => true
  end
end
