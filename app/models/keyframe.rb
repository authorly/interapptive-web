class Keyframe < ActiveRecord::Base
  belongs_to :scene
  belongs_to :preview_image, :class_name => 'Image'
  has_many :texts, :class_name => 'KeyframeText',
           :dependent => :destroy

  serialize :widgets

  validates :position, numericality: { equal_to: 0 }, if: :is_animation, allow_nil: true
  validates :is_animation, uniqueness: { scope: :scene_id }, if: :is_animation

  def as_json(options)
    super.merge({
      preview_image_url: preview_image.try(:image).try(:url)
    })
  end


  private

  def one_animation_keyframe_per_scene
    if is_animation
      animations = scene.keyframes.where(is_animation.true).reject{|k| k.id == id}
      errors[:is_animation] << :only_one
    end
  end
end
