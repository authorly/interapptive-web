class Scene < ActiveRecord::Base
  belongs_to :storybook
  has_many :keyframes
  has_many :asset_maps, :as => :assetable
  has_many :images, :through => :asset_maps, :source => :asset,
                    :conditions => { :type => 'Image' }
  has_many :sounds, :through => :asset_maps, :source => :asset,
                    :conditions => { :type => 'Sound' }
  has_many :videos, :through => :touch_zones

  has_many :actions
  has_many :touch_zones

  has_one :scene_settings
  has_many :fonts, :through => :scene_settings

  belongs_to :preview_image, :class_name => 'Image'
  belongs_to :background_image, :class_name => 'Image'
  belongs_to :background_sound, :class_name => 'Sound' 

  after_create :create_keyframe

  private

  def create_keyframe
    keyframes.create
  end
end
