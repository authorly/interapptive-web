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

  validates :position, inclusion: { in: [nil] }, if: :is_main_menu
  validates :is_main_menu, uniqueness: { scope: :storybook_id }, if: :is_main_menu

  serialize :widgets
  serialize :font_color

  before_create :create_main_menu_widgets, if: :is_main_menu
  after_create :create_keyframe

  def as_json(options)
    super.merge({
      :preview_image_url => preview_image.try(:image).try(:url),
      :sound_url         => sound_url
    })
  end

  def can_be_destroyed?
    !is_main_menu
  end

  def sound_url
    if sound.present?
      sound.sound.url
    end
  end

  private

  def create_keyframe
    keyframes.create(position: 0)
  end

  def create_main_menu_widgets
    self.widgets = [
      {type: 'ButtonWidget', id: 1, name: 'read_it_myself', position: { y: 100, x: 200 }, scale: 1, z_order: 1 },
      {type: 'ButtonWidget', id: 2, name: 'read_to_me',     position: { y: 200, x: 200 }, scale: 1, z_order: 2 },
      {type: 'ButtonWidget', id: 3, name: 'auto_play',      position: { y: 300, x: 200 }, scale: 1, z_order: 3 },
    ]
  end



end
