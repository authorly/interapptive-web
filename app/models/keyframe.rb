class Keyframe < ActiveRecord::Base
  belongs_to :scene
  has_many :texts, :class_name => 'KeyframeText'
end
