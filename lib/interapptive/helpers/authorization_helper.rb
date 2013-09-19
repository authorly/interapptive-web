module Interapptive
  module Helpers
    module AuthorizationHelper

      private

      def authorize_scene_ownership
        @scene = Scene.find(params[:scene_id])
        raise ActiveRecord::RecordNotFound unless @scene.storybook.owned_by?(signed_in_as_user)
      end

      def authorize_storybook_ownership
        @storybook = Storybook.find(params[:storybook_id])
        raise ActiveRecord::RecordNotFound unless @storybook.owned_by?(signed_in_as_user)
      end

      def find_storybook
        @storybook = signed_in_as_user.storybooks.find(params[:storybook_id])
      end
    end
  end
end
