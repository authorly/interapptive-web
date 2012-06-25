class Attribute < ActiveRecord::Base
  belongs_to :action
  belongs_to :keyframe
  belongs_to :attribute_definition
end
