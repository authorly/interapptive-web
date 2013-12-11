module Admin
  class PublishRequestsController < Admin::BaseController
    respond_to :html

    def index
      respond_with @requests = PublishRequest.includes(:storybook).where('applications_count < 3').order('created_at DESC')
    end

    def show
      respond_with @request = PublishRequest.includes(:storybook).find(params[:id])
    end

    def update
      @request = PublishRequest.find(params[:id])
      unless @request.update_attributes(params[:publish_request])
        flash[:error] = @request.errors.full_messages.join(', ')
      end

      respond_with [:admin, @request]
    end
  end

end
