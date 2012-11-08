class Keyframe < ActiveRecord::Base
  belongs_to :scene
  belongs_to :preview_image, :class_name => 'Image'
  has_many :texts, :class_name => 'KeyframeText',
           :dependent => :destroy

  serialize :widgets

  def as_json(options)
    super.merge({
      preview_image_url: preview_image.try(:image).try(:url)
    })
  end
end
