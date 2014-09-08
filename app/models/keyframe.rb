class Keyframe < ActiveRecord::Base
  include Rails.application.routes.url_helpers

  belongs_to :scene
  belongs_to :preview_image, :class_name => 'Image'
  belongs_to :voiceover, :class_name => 'Sound'

  # TODO RFCTR fix all the methods that deal with texts
  # has_many :texts, :class_name => 'KeyframeText', :dependent => :destroy

  serialize :widgets
  serialize :content_highlight_times, Array

  validates :position, inclusion: { in: [nil] }, if: :is_animation
  validates :is_animation, uniqueness: { scope: :scene_id }, if: :is_animation
  validates :animation_duration, numericality: { greater_than_or_equal_to: 0 }

  def enqueue_for_auto_alignment
    Resque.enqueue(AutoAlignmentQueue, self.id)
  end

  def audio_text
    texts.order(:sync_order).collect(&:content).join(' ')
  end

  def can_be_destroyed?
    is_animation || scene.keyframes.where(is_animation: false).length > 1
  end

  def as_json(options)
    super.merge({
      :preview_image_url => preview_image_url,
    })
  end

  def preview_image_url
    preview_image.try(:image).try(:url)
  end

  def text
    self.widgets.map { |w| w['string'] if w['type'] == 'TextWidget' }
  end

  private

  def one_animation_keyframe_per_scene
    if is_animation
      animations = scene.keyframes.where(is_animation.true).reject{|k| k.id == id}
      errors[:is_animation] << :only_one
    end
  end
end
