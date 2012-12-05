class Scene < ActiveRecord::Base
  belongs_to :storybook
  belongs_to :sound

  has_many :keyframes, :dependent => :destroy
  has_many :asset_maps, :as => :assetable,
           :dependent => :destroy
  has_many :images, :through => :asset_maps, :source => :asset,
                    :conditions => { :type => 'Image' },
                    :dependent => :destroy
  has_many :sounds, :through => :asset_maps, :source => :asset,
                    :conditions => { :type => 'Sound' },
                    :dependent => :destroy
  has_many :videos, :through => :asset_maps, :source => :asset,
                    :conditions => { :type => 'Video' },
                    :dependent => :destroy

  has_many :actions, :dependent => :destroy

  has_one :scene_settings
  has_many :fonts, :through => :scene_settings

  # has_many :attributes, :through => :actions

  belongs_to :preview_image, :class_name => 'Image'
  belongs_to :background_image, :class_name => 'Image'
  belongs_to :background_sound, :class_name => 'Sound'

  serialize :widgets

  after_create :create_keyframe

  def as_json(options)
    super.merge({
      :preview_image_url => preview_image.try(:image).try(:url),
      :sound_url         => sound_url
    })
  end

  def sound_url
    if sound.present?
      sound.sound.url
    end
  end

  private

  def create_keyframe
    keyframes.create position: 0
  end
end
