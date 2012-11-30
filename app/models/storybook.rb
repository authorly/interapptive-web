class Storybook < ActiveRecord::Base
  mount_uploader :icon, AppIconUploader

  belongs_to :user
  has_many :scenes, :dependent => :destroy

  has_many :images, :dependent => :destroy
  has_many :sounds, :dependent => :destroy
  has_many :videos, :dependent => :destroy
  has_many :fonts,  :dependent => :destroy

  has_one  :default_font, :through => :storybook_settings, :source => :font

  after_create :create_scene

  validates_presence_of :title

  private

  def create_scene
    self.scenes.create
  end
end
