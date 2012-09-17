class Keyframe < ActiveRecord::Base
  belongs_to :scene
  belongs_to :preview_image, :class_name => 'Image'
  has_many :texts, :class_name => 'KeyframeText',
           :dependent => :destroy

  serialize :widgets
end
