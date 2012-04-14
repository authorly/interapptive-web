class SceneAttribute < ActiveRecord::Base
  belongs_to :keyframe
  belongs_to :attribute
  belongs_to :action_group
end
