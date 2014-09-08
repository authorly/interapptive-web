module Admin
  class AutoAlignmentsController < Admin::BaseController
    def create
      keyframe = Keyframe.find(params[:keyframe_id])
      keyframe.enqueue_for_auto_alignment

      respond_to do |format|
        format.json { head :no_content }
      end
    end
  end
end
