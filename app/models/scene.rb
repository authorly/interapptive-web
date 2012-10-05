class Scene < ActiveRecord::Base
  belongs_to :storybook
  has_many :keyframes, :dependent => :destroy
  has_many :asset_maps, :as => :assetable,
           :dependent => :destroy
  has_many :images, :through => :asset_maps, :source => :asset,
                    :conditions => { :type => 'Image' },
                    :dependent => :destroy
  has_many :sounds, :through => :asset_maps, :source => :asset,
                    :conditions => { :type => 'Sound' },
                    :dependent => :destroy


  has_many :actions, :dependent => :destroy

  has_one :scene_settings
  has_many :fonts, :through => :scene_settings

  # has_many :attributes, :through => :actions

  belongs_to :preview_image, :class_name => 'Image'
  belongs_to :background_image, :class_name => 'Image'
  belongs_to :background_sound, :class_name => 'Sound' 

  after_create :create_keyframe

  private

  def create_keyframe
    keyframes.create
  end
end
